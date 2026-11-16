import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
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
        // Bank redirects remain inside the WebView. A redirect is never treated
        // as proof of payment; confirmation belongs to the merchant backend.
        onNavigationRequest: (request) {
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
      child: _error != null
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
