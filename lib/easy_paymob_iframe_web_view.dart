part of 'easy_payment.dart';

class EasyPaymobIFrameWebView extends StatefulWidget {
  const EasyPaymobIFrameWebView({
    Key? key,
    required this.redirectURL,
    this.onPayment,
  }) : super(key: key);

  final String redirectURL;
  final void Function(EasyPaymobResponse)? onPayment;

  static Future<EasyPaymobResponse?> show({
    required BuildContext context,
    required String redirectURL,
    void Function(EasyPaymobResponse)? onPayment,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return EasyPaymobIFrameWebView(
              onPayment: onPayment,
              redirectURL: redirectURL,
            );
          },
        ),
      );

  @override
  State<EasyPaymobIFrameWebView> createState() => _EasyPaymobIFrameWebViewState();
}

class _EasyPaymobIFrameWebViewState extends State<EasyPaymobIFrameWebView> {
  WebViewController? controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('txn_response_code') && request.url.contains('success') && request.url.contains('id')) {
              final params = _getParamFromURL(request.url);
              final response = EasyPaymobResponse.fromJson(params);
              if (widget.onPayment != null) {
                widget.onPayment!(response);
              }
              Navigator.pop(context, response);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectURL));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller == null
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : SafeArea(
              child: WebViewWidget(
                controller: controller!,
              ),
            ),
    );
  }

  Map<String, dynamic> _getParamFromURL(String url) {
    final uri = Uri.parse(url);
    Map<String, dynamic> data = {};
    uri.queryParameters.forEach((key, value) {
      data[key] = value;
    });
    log(jsonEncode(data));

    return data;
  }
}
