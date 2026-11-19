package com.joytech.hexcy

import android.content.Intent
import android.content.pm.PackageManager
import com.kbzbank.payment.KBZPay
import android.net.Uri
import android.telecom.TelecomManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.pg.sdk.PaymentManager
import com.pg.sdk.config.PaymentSdkConfig
import com.pg.sdk.models.PaymentResult
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    companion object {
        internal const val KBZPAY_RETURN_ORDER_ID = "com.joytech.hexcy.KBZPAY_RETURN_ORDER_ID"
        private const val KBZPAY_UAT_PACKAGE = "com.kbzbank.kpaycustomer.uat"
        internal var activeKbzPayOrderId: String? = null
            private set
    }

    private var kbzPayChannel: MethodChannel? = null
    private val pgScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var activePgOrderId: String? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val orderId = intent.getStringExtra(KBZPAY_RETURN_ORDER_ID)
        if (orderId != null && orderId == activeKbzPayOrderId) {
            activeKbzPayOrderId = null
            kbzPayChannel?.invokeMethod("paymentReturned", orderId)
        }
        handlePgPaymentResult(intent)
    }

    override fun onDestroy() {
        pgScope.cancel()
        super.onDestroy()
    }

    /** PGInAppSDK returns here (setReturnActivity) with the payment outcome. */
    private fun handlePgPaymentResult(intent: Intent) {
        val status = intent.getStringExtra("extra_payment_status") ?: return
        val orderId = intent.getStringExtra("extra_merchant_order_id")
        if (orderId == null || orderId != activePgOrderId) return
        activePgOrderId = null
        kbzPayChannel?.invokeMethod(
            "pgPaymentResult",
            mapOf(
                "status" to status,
                "merchantOrderId" to orderId,
                "message" to intent.getStringExtra("extra_message"),
            ),
        )
    }

    private fun pgConfigured(): Boolean = listOf(
        BuildConfig.PG_BASE_URL, BuildConfig.PG_CLIENT_ID, BuildConfig.PG_API_KEY,
        BuildConfig.PG_APP_ID, BuildConfig.PG_MERCHANT_CODE,
    ).all { it.isNotBlank() }

    private fun pgBaseUrl(): String = BuildConfig.PG_BASE_URL.trimEnd('/') + "/"

    /** POST api/auth/request-token with ClientId + Apikey and return the bearer token. */
    private fun requestPgToken(): String {
        val body = JSONObject()
            .put("ClientId", BuildConfig.PG_CLIENT_ID)
            .put("Apikey", BuildConfig.PG_API_KEY)
            .toString()
            .toRequestBody("application/json".toMediaType())
        val client = OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .build()
        val request = Request.Builder()
            .url(pgBaseUrl() + "api/auth/request-token")
            .post(body)
            .build()
        client.newCall(request).execute().use { response ->
            val text = response.body?.string().orEmpty()
            if (!response.isSuccessful) throw IllegalStateException("Token request failed (${response.code}).")
            val token = JSONObject(text).optJSONObject("data")?.optString("accessToken").orEmpty()
            if (token.isBlank()) throw IllegalStateException("Token response had no access token.")
            return token
        }
    }

    private fun startPgSdkPayment(
        orderId: String,
        amount: Double,
        email: String,
        description: String,
        result: MethodChannel.Result,
    ) {
        pgScope.launch {
            try {
                val token = withContext(Dispatchers.IO) { requestPgToken() }
                PaymentSdkConfig.initialize(pgBaseUrl(), token)
                PaymentManager.setReturnActivity(MainActivity::class.java.name)
                activePgOrderId = orderId
                val error = PaymentManager().createPayment(
                    context = this@MainActivity,
                    merchantOrderId = orderId,
                    merchantId = BuildConfig.PG_CLIENT_ID,
                    amount = amount,
                    serviceCharges = 0.0,
                    email = email,
                    currency = "MMK",
                    description = description,
                    title = "HEXCY Checkout",
                    appId = BuildConfig.PG_APP_ID,
                    merchantCode = BuildConfig.PG_MERCHANT_CODE,
                )
                if (error == null) {
                    result.success(null) // SDK checkout screen is now open.
                } else {
                    activePgOrderId = null
                    val message = (error as? PaymentResult.Error)?.message ?: "Payment initiation failed."
                    result.error("PG_PAYMENT_FAILED", message, null)
                }
            } catch (error: Exception) {
                activePgOrderId = null
                result.error("PG_PAYMENT_FAILED", error.message ?: "Payment initiation failed.", null)
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun isKbzPayUatAvailable(): Boolean {
        return try {
            val wallet = packageManager.getPackageInfo(KBZPAY_UAT_PACKAGE, 0)
            val version = wallet.versionName?.substringBefore('.')?.toIntOrNull()
            version != null && version >= 2 && wallet.applicationInfo?.enabled == true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        kbzPayChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.hexcy/kbzpay",
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method == "startPgSdkPayment") {
                    val orderId = call.argument<String>("merchantOrderId")
                    val amount = call.argument<Number>("amount")?.toDouble()
                    if (!pgConfigured()) {
                        result.error("PG_NOT_CONFIGURED", "PG SDK settings are missing.", null)
                    } else if (orderId.isNullOrBlank() || amount == null || amount <= 0 || amount > 10_000_000) {
                        result.error("INVALID_PAYMENT", "Missing KBZPay payment data.", null)
                    } else {
                        startPgSdkPayment(
                            orderId,
                            amount,
                            call.argument<String>("email")?.takeIf { it.isNotBlank() } ?: "customer@example.com",
                            call.argument<String>("description").orEmpty().ifBlank { "Payment for $orderId" },
                            result,
                        )
                    }
                    return@setMethodCallHandler
                }
                if (call.method != "startPayment") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val orderInfo = call.argument<String>("orderInfo")
                val sign = call.argument<String>("sign")
                val orderId = call.argument<String>("orderId")
                if (orderInfo.isNullOrBlank() || sign.isNullOrBlank() || orderId.isNullOrBlank()) {
                    result.error("INVALID_PAYMENT", "Missing KBZPay payment data.", null)
                    return@setMethodCallHandler
                }
                if (!isKbzPayUatAvailable()) {
                    result.error("KBZPAY_UNAVAILABLE", "Install or update the KBZPay UAT wallet.", null)
                    return@setMethodCallHandler
                }
                try {
                    activeKbzPayOrderId = orderId
                    KBZPay.startPay(this, orderInfo, sign, "SHA256")
                    result.success(null)
                } catch (_: Exception) {
                    activeKbzPayOrderId = null
                    result.error("KBZPAY_LAUNCH_FAILED", "Could not open the KBZPay wallet.", null)
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "mobile_hexy/phone",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openDialer") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val number = call.argument<String>("number").orEmpty()
            if (number.isBlank()) {
                result.error("INVALID_NUMBER", "A phone number is required.", null)
                return@setMethodCallHandler
            }

            try {
                val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number"))
                val telecomManager = getSystemService(TELECOM_SERVICE) as TelecomManager
                telecomManager.defaultDialerPackage
                    ?.takeIf { it.isNotBlank() }
                    ?.let(intent::setPackage)
                startActivity(intent)
                result.success(true)
            } catch (error: Exception) {
                result.error("DIALER_UNAVAILABLE", error.message, null)
            }
        }
    }
}
