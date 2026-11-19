import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({
    super.key,
    required this.session,
    this.controllerFactory,
  });
  final PaymentCheckoutSession session;
  @visibleForTesting
  final Future<WebViewController> Function()? controllerFactory;

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage>
    with WidgetsBindingObserver {
  static const _kbzPayChannel = MethodChannel('com.hexcy/kbzpay');
  bool _openingWallet = false;
  bool _waitingForWallet = false;
  bool _leftAppForWallet = false;

  bool get _isKbzPay => PaymentCheckoutSession.isKbzPay(
    widget.session.orderDetails['payment_method'],
  );
  bool get _usesNativeKbzPay =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) &&
      widget.session.kbzPayArguments != null;

  /// iOS: the PG web checkout does not open KBZPay itself, so (like
  /// PGInAppSDK) we catch its KBZPay submit and launch the wallet natively.
  bool get _usesPgKbzBridge =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      _isKbzPay &&
      !_usesNativeKbzPay;

  /// Android: KBZPay without native data goes through PGInAppSDK
  /// (PaymentManager.createPayment). Falls back to the web checkout on error.
  bool get _usesPgSdk =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      _isKbzPay &&
      !_usesNativeKbzPay;

  Future<bool> _startPgSdkPayment() async {
    final orderId = _pgMerchantOrderId;
    final amount = num.tryParse(
      widget.session.orderDetails['amount']?.toString() ?? '',
    );
    if (orderId == null || amount == null || amount <= 0) return false;
    setState(() {
      _error = null;
      _waitingForWallet = true;
    });
    try {
      await _kbzPayChannel.invokeMethod<void>('startPgSdkPayment', {
        'merchantOrderId': orderId,
        'amount': amount.toDouble(),
        'description': 'Payment for $orderId',
      });
      return true;
    } catch (error) {
      debugPrint('PG SDK payment start failed: ${error.runtimeType}');
      if (mounted) setState(() => _waitingForWallet = false);
      return false;
    }
  }

  void _onPgSdkResult(Object? arguments) {
    if (arguments is! Map ||
        arguments['merchantOrderId'] != _pgMerchantOrderId) {
      return;
    }
    final status = arguments['status']?.toString().toUpperCase();
    if (status == 'SUCCESS') {
      _startPaymentVerification();
      return;
    }
    if (!mounted) return;
    _paymentStatusTimer?.cancel();
    _completed = true;
    _attempt++;
    setState(() {
      _waitingForWallet = false;
      _checkingPayment = false;
      _paymentMessage = switch (status) {
        'EXPIRED' || 'TIMEOUT' => 'The payment session expired.',
        _ => 'The payment failed.',
      };
    });
  }

  String? get _pgMerchantOrderId {
    final id = widget.session.orderDetails['transaction_id']?.toString().trim();
    return id == null || id.isEmpty ? null : id;
  }

  static const _pgSubmitHookJs = '''
(function() {
  function hook() {
    var btn = document.getElementById('btnSubmit');
    if (!btn) { setTimeout(hook, 500); return; }
    if (btn.dataset.hexyKbzHook) return;
    btn.dataset.hexyKbzHook = '1';
    btn.addEventListener('click', function() {
      var card = document.querySelector('.method-card.selected');
      var name = card && card.querySelector('.method-name');
      HexyKbzBridge.postMessage(name ? (name.textContent || '').trim() : '');
    });
  }
  hook();
})();
''';

  Future<void> _onPgSubmit(String methodName, int attempt) async {
    if (!mounted || attempt != _attempt || _completed || _waitingForWallet) {
      return;
    }
    if (methodName.trim().toLowerCase() != 'kbzpay') return;
    final orderId = _pgMerchantOrderId;
    final amount = num.tryParse(
      widget.session.orderDetails['amount']?.toString() ?? '',
    );
    if (orderId == null || amount == null) {
      _showKbzError('Missing KBZPay payment data.');
      return;
    }
    setState(() => _waitingForWallet = true);
    try {
      await _kbzPayChannel.invokeMethod<void>('startPgKbzPay', {
        'merchantOrderId': orderId,
        'amount': amount.toStringAsFixed(0),
        'notifyBaseUrl': 'https://paymentaggregatoruat.kbzbank.com',
      });
    } on PlatformException catch (error) {
      if (!mounted || _completed) return;
      setState(() => _waitingForWallet = false);
      _showKbzError(error.message ?? 'Could not open the KBZPay wallet.');
    } catch (_) {
      if (!mounted || _completed) return;
      setState(() => _waitingForWallet = false);
      _showKbzError('Could not open the KBZPay wallet.');
    }
  }

  void _showKbzError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  WebViewController? _controller;
  int _progress = 0;
  String? _error;
  String? _currentPageUrl;
  int _attempt = 0;
  bool _completed = false;
  bool _checkingPayment = false;
  Timer? _paymentStatusTimer;
  String? _paymentMessage;

  bool _handleCompletion(String url) {
    final status = widget.session.completionStatus(url);
    if (!mounted || _completed || status == null) {
      return false;
    }
    _completed = true;
    _attempt++;
    // The redirect signals that it is time to verify the payment.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _finishCompletion(status);
    });
    WidgetsBinding.instance.scheduleFrame();
    return true;
  }

  Future<void> _finishCompletion(PaymentCompletionStatus status) async {
    if (!mounted) return;
    if (status == PaymentCompletionStatus.success) {
      _startPaymentVerification();
      return;
    }
    try {
      await _controller?.clearCache();
    } catch (error) {
      debugPrint('Payment WebView cache clearing failed: ${error.runtimeType}');
    }
    if (!mounted) return;
    Get.offNamed<dynamic>(
      AppRoutes.checkout,
      arguments: widget.session.orderDetails,
    );
  }

  void _startPaymentVerification() {
    if (!mounted || _checkingPayment || _paymentMessage != null) return;
    _completed = true;
    _attempt++;
    setState(() => _checkingPayment = true);
    unawaited(_checkPaymentStatus());
  }

  Future<void> _startKbzPay() async {
    if (_usesPgSdk && await _startPgSdkPayment()) return;
    if (!mounted) return;
    if (!_usesNativeKbzPay) {
      await _openCheckout();
      return;
    }
    setState(() {
      _error = null;
      _waitingForWallet = true;
    });
    try {
      await _kbzPayChannel.invokeMethod<void>(
        'startPayment',
        widget.session.kbzPayArguments,
      );
    } catch (_) {
      if (!mounted || _completed) return;
      setState(() => _waitingForWallet = false);
      await _openCheckout();
    }
  }

  Future<void> _openExternalPayment(Uri uri) async {
    if (_openingWallet || _waitingForWallet || _completed) return;
    _openingWallet = true;
    _waitingForWallet = true;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('Payment handoff failed: ${error.runtimeType}');
    } finally {
      _openingWallet = false;
    }
    if (opened || !mounted || _completed) return;
    _waitingForWallet = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the KBZPay payment link.')),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_waitingForWallet || _completed) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _leftAppForWallet = true;
    } else if (state == AppLifecycleState.resumed && _leftAppForWallet) {
      _startPaymentVerification();
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final payment = await Get.find<CheckoutRemoteDataSource>()
          .fetchPaymentStatus(widget.session.orderDetails);
      if (!mounted) return;
      final status = payment['status']?.toString().trim().toLowerCase();
      if (const {'paid', 'success', 'succeeded', 'done'}.contains(status)) {
        Get.offNamed<dynamic>(
          AppRoutes.paymentSuccess,
          arguments: {...widget.session.orderDetails, ...payment},
        );
        return;
      }
      final terminalMessage = switch (status) {
        'failed' || 'error' => 'The payment failed.',
        'cancelled' || 'canceled' => 'The payment was cancelled.',
        _ => null,
      };
      if (terminalMessage != null) {
        setState(() {
          _checkingPayment = false;
          _paymentMessage = terminalMessage;
        });
        return;
      }
    } catch (error) {
      debugPrint('Payment status check failed: ${error.runtimeType}');
    }

    // Wait for this request to finish before scheduling the next one.
    if (mounted) {
      _paymentStatusTimer = Timer(
        const Duration(seconds: 1),
        _checkPaymentStatus,
      );
    }
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (_usesNativeKbzPay || _usesPgKbzBridge || _usesPgSdk) {
      _kbzPayChannel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_usesNativeKbzPay) {
      _kbzPayChannel.setMethodCallHandler((call) async {
        if (call.method == 'paymentReturned' &&
            call.arguments == widget.session.kbzPayArguments?['orderId']) {
          _startPaymentVerification();
        }
      });
    } else if (_usesPgSdk) {
      _kbzPayChannel.setMethodCallHandler((call) async {
        if (call.method == 'pgPaymentResult') _onPgSdkResult(call.arguments);
      });
    } else if (_usesPgKbzBridge) {
      _kbzPayChannel.setMethodCallHandler((call) async {
        if (call.method == 'paymentReturned' &&
            _waitingForWallet &&
            call.arguments == _pgMerchantOrderId) {
          _startPaymentVerification();
        }
      });
    }
    // Render the new route before initializing the native platform view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_startKbzPay());
    });
  }

  Future<void> _openCheckout() async {
    final url = widget.session.url;
    if (url == null) {
      setState(
        () => _error =
            'Could not open the KBZPay wallet. Check that it is installed.',
      );
      return;
    }
    final attempt = ++_attempt;
    setState(() {
      _error = null;
      _progress = 0;
      _controller = null;
    });
    try {
      await _configureCheckout(
        attempt,
        url,
      ).timeout(const Duration(seconds: 20));
    } catch (error) {
      // Do not log the checkout token or any card details.
      debugPrint('Payment WebView initialization failed: ${error.runtimeType}');
      if (mounted && attempt == _attempt) {
        _attempt++; // Ignore late callbacks from a timed-out initialization.
        setState(
          () => _error = error is TimeoutException
              ? 'The payment page took too long to open. Please try again.'
              : 'Unable to open the payment page. Please restart the app and try again.',
        );
      }
    }
  }

  Future<void> _configureCheckout(int attempt, Uri checkoutUrl) async {
    final controller =
        await (widget.controllerFactory?.call() ??
            Future.value(WebViewController()));
    if (!mounted || attempt != _attempt) return;
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.white);
    if (_usesPgKbzBridge) {
      await controller.addJavaScriptChannel(
        'HexyKbzBridge',
        onMessageReceived: (message) =>
            unawaited(_onPgSubmit(message.message, attempt)),
      );
    }
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (value) {
          if (mounted && attempt == _attempt) setState(() => _progress = value);
        },
        onPageStarted: (url) {
          if (_handleCompletion(url)) return;
          _currentPageUrl = url;
          if (mounted && attempt == _attempt) {
            setState(() {
              _error = null;
              _progress = 0;
            });
          }
        },
        onPageFinished: (url) {
          final page = Uri.tryParse(url);
          if (_usesPgKbzBridge &&
              mounted &&
              attempt == _attempt &&
              page != null &&
              PaymentCheckoutSession.isKbzPayUatOrigin(page)) {
            unawaited(
              controller
                  .runJavaScript(_pgSubmitHookJs)
                  .catchError((Object _) {}),
            );
          }
        },
        onWebResourceError: (error) {
          if (mounted && attempt == _attempt && error.isForMainFrame == true) {
            setState(
              () =>
                  _error = 'Unable to load the payment page. Please try again.',
            );
          }
        },
        onHttpError: (error) {
          if (mounted &&
              attempt == _attempt &&
              error.request?.uri.toString() == _currentPageUrl &&
              (error.response?.statusCode ?? 0) >= 400) {
            setState(
              () =>
                  _error = 'The payment page is unavailable. Please try again.',
            );
          }
        },
        onUrlChange: (change) {
          if (change.url != null) _handleCompletion(change.url!);
        },
        onNavigationRequest: (request) {
          if (!mounted || attempt != _attempt || _completed) {
            return NavigationDecision.prevent;
          }
          if (request.isMainFrame && _handleCompletion(request.url)) {
            return NavigationDecision.prevent;
          }
          final uri = Uri.tryParse(request.url);
          final source = Uri.tryParse(_currentPageUrl ?? '');
          if (_isKbzPay &&
              request.isMainFrame &&
              uri?.scheme == 'kbzpay' &&
              source != null &&
              PaymentCheckoutSession.isKbzPayUatOrigin(source) &&
              PaymentCheckoutSession.isKbzPayUatOrigin(checkoutUrl)) {
            unawaited(_openExternalPayment(uri!));
            return NavigationDecision.prevent;
          }
          return uri != null && uri.scheme == 'https'
              ? NavigationDecision.navigate
              : NavigationDecision.prevent;
        },
      ),
    );
    if (!mounted || attempt != _attempt) return;
    setState(() {
      _controller = controller;
      _error = null;
      _progress = 0;
    });
    // Merchant API credentials are deliberately not attached to bank requests.
    await controller.loadRequest(checkoutUrl);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.session.title),
      actions: [
        if (widget.session.url case final url?
            when _isKbzPay &&
                !_checkingPayment &&
                !_waitingForWallet &&
                _paymentMessage == null &&
                PaymentCheckoutSession.isKbzPayUatOrigin(url))
          IconButton(
            tooltip: 'Open checkout in browser',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openExternalPayment(url),
          ),
      ],
    ),
    body: SafeArea(
      child: _checkingPayment || _paymentMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_checkingPayment) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Checking payment status…'),
                    ] else ...[
                      Text(_paymentMessage!, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            )
          : (_usesNativeKbzPay || _usesPgKbzBridge || _usesPgSdk) &&
                _waitingForWallet
          ? const Center(child: Text('Complete your payment in KBZPay.'))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: widget.session.url == null
                          ? _startKbzPay
                          : _openCheckout,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (_progress < 100)
                  LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                  ),
                Expanded(
                  child: _controller == null
                      ? const SizedBox.shrink()
                      : WebViewWidget(controller: _controller!),
                ),
              ],
            ),
    ),
  );
}
