import CryptoKit
import Flutter
import KBZPayAPPPay
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static var kbzPayScheme: String {
    "\(Bundle.main.bundleIdentifier ?? "").kbzpay"
  }

  private var kbzPayChannel: FlutterMethodChannel?

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.hexcy/kbzpay", binaryMessenger: engineBridge.applicationRegistrar.messenger())
    kbzPayChannel = channel
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isAvailable":
        result(Self.canOpenKBZPay)
      case "startPayment":
        guard let arguments = call.arguments as? [String: String],
              let orderInfo = arguments["orderInfo"], !orderInfo.isEmpty,
              let sign = arguments["sign"], !sign.isEmpty else {
          result(FlutterError(code: "INVALID_PAYMENT", message: "Missing KBZPay payment data.", details: nil))
          return
        }
        guard Self.canOpenKBZPay else {
          result(FlutterError(code: "KBZPAY_UNAVAILABLE", message: "Install the KBZPay app on your iPhone.", details: nil))
          return
        }
        PaymentViewController().startPay(
          withOrderInfo: orderInfo, signType: "SHA256", sign: sign, appScheme: Self.kbzPayScheme)
        result(nil)
      case "startPgKbzPay":
        // KBZPay selected on the PG web checkout (same flow as PGInAppSDK).
        guard let arguments = call.arguments as? [String: String],
              let orderId = arguments["merchantOrderId"],
              orderId.range(of: "^[A-Za-z0-9_-]{1,64}$", options: .regularExpression) != nil,
              let amount = arguments["amount"],
              amount.range(of: "^[0-9]{1,12}$", options: .regularExpression) != nil,
              let notifyBase = arguments["notifyBaseUrl"],
              notifyBase == PGKBZPay.uatGatewayOrigin else {
          result(FlutterError(code: "INVALID_PAYMENT", message: "Missing KBZPay payment data.", details: nil))
          return
        }
        guard Self.canOpenKBZPay else {
          result(FlutterError(code: "KBZPAY_UNAVAILABLE", message: "Install the KBZPay app on your iPhone.", details: nil))
          return
        }
        PGKBZPay.precreate(merchantOrderId: orderId, amount: amount, notifyBase: notifyBase) { outcome in
          DispatchQueue.main.async {
            switch outcome {
            case .success(let prepayId):
              let launch = PGKBZPay.launchArguments(prepayId: prepayId)
              PaymentViewController().startPay(
                withOrderInfo: launch.orderInfo, signType: "SHA256", sign: launch.sign,
                appScheme: Self.kbzPayScheme)
              result(nil)
            case .failure(let message):
              result(FlutterError(code: "KBZPAY_PRECREATE_FAILED", message: message, details: nil))
            }
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static var canOpenKBZPay: Bool {
    #if targetEnvironment(simulator)
    return false
    #else
    guard let url = URL(string: "kbzpay://") else { return false }
    return UIApplication.shared.canOpenURL(url)
    #endif
  }

  @discardableResult
  static func handleKBZPayURL(_ url: URL) -> Bool {
    guard url.scheme?.lowercased() == kbzPayScheme.lowercased() else { return false }
    let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    let orderIDs = items.filter { $0.name == "EXTRA_ORDER_ID" }
    if orderIDs.count == 1, let orderID = orderIDs.first?.value, !orderID.isEmpty,
       let delegate = UIApplication.shared.delegate as? AppDelegate {
      delegate.kbzPayChannel?.invokeMethod("paymentReturned", arguments: orderID)
    }
    return true
  }

  override func application(
    _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Self.handleKBZPayURL(url) { return true }
    return super.application(app, open: url, options: options)
  }
}

// MARK: - PG KBZPay (ported from PGInAppSDK 1.x, UAT only)

enum PGKBZPay {
  enum Outcome {
    case success(String)
    case failure(String)
  }

  static let uatGatewayOrigin = "https://paymentaggregatoruat.kbzbank.com"
  // Values supplied by the PG aggregator's PGInAppSDK (UAT).
  private static let appId = "kpe1107bc526d403dd7431c794a3eb80"
  private static let merchantCode = "70477201"
  private static let signKey = "acedatasystem@123"
  private static let precreateURL = URL(string: "http://api-uat.kbzpay.com/payment/gateway/uat/precreate")!

  private static func nonce() -> String { String(UInt64.random(in: 1...UInt64.max)) }
  private static func timestamp() -> String { String(Int(Date().timeIntervalSince1970)) }

  /// SHA256(sorted non-empty "k=v&" pairs + "key=<signKey>"), uppercase hex.
  private static func sign(_ fields: [String: String]) -> String {
    let base = fields
      .filter { $0.key != "sign" && $0.key != "sign_type" && !$0.value.isEmpty }
      .sorted { $0.key < $1.key }
      .map { "\($0.key)=\($0.value)&" }
      .joined() + "key=\(signKey)"
    return SHA256.hash(data: Data(base.utf8)).map { String(format: "%02X", $0) }.joined()
  }

  static func precreate(
    merchantOrderId: String, amount: String, notifyBase: String,
    completion: @escaping (Outcome) -> Void
  ) {
    let nonceStr = nonce()
    let time = timestamp()
    let notifyUrl = "\(notifyBase)/payment/notify"
    let biz: [String: String] = [
      "appid": appId,
      "callback_info": "callbackinfo_test",
      "merch_code": merchantCode,
      "merch_order_id": merchantOrderId,
      "timeout_express": "100m",
      "title": "Payment From iOS App",
      "total_amount": amount,
      "trade_type": "APP",
      "trans_currency": "MMK",
    ]
    var signFields = biz
    signFields.merge([
      "method": "kbz.payment.precreate", "nonce_str": nonceStr, "notify_url": notifyUrl,
      "timestamp": time, "version": "1.0",
    ]) { $1 }
    let body: [String: Any] = [
      "Request": [
        "biz_content": biz,
        "method": "kbz.payment.precreate",
        "nonce_str": nonceStr,
        "notify_url": notifyUrl,
        "sign": sign(signFields),
        "sign_type": "SHA256",
        "timestamp": time,
        "version": "1.0",
      ]
    ]
    var request = URLRequest(url: precreateURL, timeoutInterval: 30)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
    URLSession.shared.dataTask(with: request) { data, _, error in
      if error != nil {
        completion(.failure("Cannot connect to KBZPay. Please check your internet connection."))
        return
      }
      guard let data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let response = json["Response"] as? [String: Any] else {
        completion(.failure("Invalid response from KBZPay. Please try again."))
        return
      }
      let ok = (response["result"] as? String) == "SUCCESS" || (response["code"] as? String) == "0"
      if ok, let prepayId = response["prepay_id"] as? String, !prepayId.isEmpty {
        completion(.success(prepayId))
      } else {
        let msg = (response["msg"] as? String) ?? (response["code"] as? String) ?? "Unknown error"
        completion(.failure("KBZPay error: \(msg)"))
      }
    }.resume()
  }

  static func launchArguments(prepayId: String) -> (orderInfo: String, sign: String) {
    let nonceStr = nonce()
    let time = timestamp()
    let fields = [
      "appid": appId, "merch_code": merchantCode, "nonce_str": nonceStr,
      "prepay_id": prepayId, "timestamp": time,
    ]
    let orderInfo =
      "appid=\(appId)&merch_code=\(merchantCode)&nonce_str=\(nonceStr)&prepay_id=\(prepayId)&timestamp=\(time)"
    return (orderInfo, sign(fields))
  }
}
