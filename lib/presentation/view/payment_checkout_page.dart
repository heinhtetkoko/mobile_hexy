import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
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

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
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
      setState(() => _checkingPayment = true);
      await _checkPaymentStatus();
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Render the new route before initializing the native platform view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openCheckout();
    });
  }

  Future<void> _openCheckout() async {
    final attempt = ++_attempt;
    setState(() {
      _error = null;
      _progress = 0;
      _controller = null;
    });
    try {
      await _configureCheckout(attempt).timeout(const Duration(seconds: 20));
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

  Future<void> _configureCheckout(int attempt) async {
    final controller =
        await (widget.controllerFactory?.call() ??
            Future.value(WebViewController()));
    if (!mounted || attempt != _attempt) return;
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.white);
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
          if (request.isMainFrame && _handleCompletion(request.url)) {
            return NavigationDecision.prevent;
          }
          final uri = Uri.tryParse(request.url);
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
    await controller.loadRequest(widget.session.url);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.session.title)),
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
                      onPressed: _openCheckout,
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
