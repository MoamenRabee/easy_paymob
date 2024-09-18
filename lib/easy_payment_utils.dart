part of 'easy_payment.dart';

class EasyPaymob {
  static EasyPaymob instance = EasyPaymob();

  bool _isInitialized = false;

  final Dio _dio = Dio();
  final _baseURL = 'https://accept.paymob.com/api/';
  late String _apiKey;
  late int? _integrationCardID;
  late int? _integrationCashID;
  late int? _integrationKioskIID;
  late int? _iFrameID;
  late String _iFrameURL;
  late int _userTokenExpiration;
  final String _currency = 'EGP';

  /// Initializing EasyPaymob instance.
  Future<bool> initialize({
    /// It is a unique identifier for the merchant which used to authenticate your requests calling any of Accept's API.
    /// from dashboard Select Settings -> Account Info -> API Key
    required String apiKey,

    /// from dashboard Select Developers -> Payment Integrations -> Online Card ID
    required int? integrationCardID,

    /// from dashboard Select Developers -> Payment Integrations -> Mobile Wallet ID
    required int? integrationCashID,

    /// from dashboard Select Developers -> Payment Integrations -> Kiosk ID
    required int? integrationKioskID,

    /// from paymob Select Developers -> iframes
    required int? iFrameID,

    /// The expiration time of this payment token in seconds. (The maximum is 3600 seconds which is an hour)
    int userTokenExpiration = 3600,
  }) async {
    if (_isInitialized) {
      return true;
    }
    _dio.options.baseUrl = _baseURL;
    _dio.options.validateStatus = (status) => true;
    _apiKey = apiKey;
    _integrationCardID = integrationCardID;
    _integrationCashID = integrationCashID;
    _integrationKioskIID = integrationKioskID;
    _iFrameID = iFrameID;
    _iFrameURL = 'https://accept.paymobsolutions.com/api/acceptance/iframes/$_iFrameID?payment_token=';
    _isInitialized = true;
    _userTokenExpiration = userTokenExpiration;
    return _isInitialized;
  }

  /// Get authentication token, which is valid for one hour from the creation time.
  Future<String> _getAuthToken() async {
    try {
      final response = await _dio.post(
        'auth/tokens',
        data: {
          'api_key': _apiKey,
        },
      );
      return response.data['token'];
    } catch (e) {
      rethrow;
    }
  }

  /// At this step, you will register an order to Accept's database, so that you can pay for it later using a transaction
  Future<int> _addOrder({
    required String authToken,
    required String currency,
    required String amount,
    required List items,
  }) async {
    try {
      final response = await _dio.post(
        'ecommerce/orders',
        data: {
          "auth_token": authToken,
          "delivery_needed": "false",
          "amount_cents": amount,
          "currency": currency,
          "items": items,
        },
      );
      return response.data['id'];
    } catch (e) {
      rethrow;
    }
  }

  /// At this step, you will obtain a payment_key token. This key will be used to authenticate your payment request. It will be also used for verifying your transaction request metadata.
  Future<String> _getPurchaseToken({
    required String authToken,
    required String currency,
    required int orderID,
    required String amount,
    required int integrationId,
    required EasyPaymobBillingModel billingData,
  }) async {
    final response = await _dio.post(
      'acceptance/payment_keys',
      data: {
        "auth_token": authToken,
        "amount_cents": amount,
        "expiration": _userTokenExpiration,
        "order_id": orderID,
        "billing_data": billingData,
        "currency": currency,
        "integration_id": integrationId,
        "lock_order_when_paid": "false",
      },
    );
    final message = response.data['message'];
    if (message != null) {
      throw Exception(message);
    }
    return response.data['token'];
  }

  /// Proceed to pay with only calling this function.
  /// Opens a WebView at Paymob redirectedURL to accept user payment info.
  Future<EasyPaymobResponse?> payWithCard(
      {
      /// BuildContext for navigation to WebView
      required BuildContext context,

      /// Payment amount in cents EX: 20000 is an 200 EGP
      required String amountInCents,

      /// Optional Callback if you can use return result of pay function or use this callback
      void Function(EasyPaymobResponse response)? onPayment,

      /// list of json objects contains the contents of the purchase.
      List? items,

      /// The billing data related to the customer related to this payment.
      EasyPaymobBillingModel? billingData}) async {
    if (!_isInitialized) {
      throw Exception('PaymobPayment is not initialized call:`PaymobPayment.instance.initialize`');
    }

    if (_integrationCardID == null || _iFrameID == null) {
      throw Exception('PaymobPayment is not initialized integrationCardID And iFrameID');
    }
    final authToken = await _getAuthToken();
    final orderID = await _addOrder(
      authToken: authToken,
      currency: _currency,
      amount: amountInCents,
      items: items ?? [],
    );
    final purchaseToken = await _getPurchaseToken(
      authToken: authToken,
      currency: _currency,
      orderID: orderID,
      amount: amountInCents,
      integrationId: _integrationCardID!,
      billingData: billingData ?? EasyPaymobBillingModel(),
    );
    if (context.mounted) {
      final response = await EasyPaymobIFrameWebView.show(
        context: context,
        redirectURL: _iFrameURL + purchaseToken,
        onPayment: onPayment,
      );
      return response;
    }
    return null;
  }

  /// Proceed to pay with only calling this function.
  /// Opens a WebView at Paymob redirectedURL to accept user payment info.
  Future<EasyPaymobResponse?> payWithWallet({
    /// BuildContext for navigation to WebView
    required BuildContext context,

    /// Payment amount in cents EX: 20000 is an 200 EGP
    required String amountInCents,

    /// Payment Number Cash EX:01273308123
    required String phoneNumber,

    /// Optional Callback if you can use return result of pay function or use this callback
    void Function(EasyPaymobResponse response)? onPayment,

    /// list of json objects contains the contents of the purchase.
    List? items,

    /// The billing data related to the customer related to this payment.
    EasyPaymobBillingModel? billingData,
  }) async {
    if (!_isInitialized) {
      throw Exception('PaymobPayment is not initialized call:`PaymobPayment.instance.initialize`');
    }

    if (_integrationCashID == null) {
      throw Exception('PaymobPayment is not initialized integrationCashID');
    }

    final authToken = await _getAuthToken();
    final orderID = await _addOrder(
      authToken: authToken,
      currency: _currency,
      amount: amountInCents,
      items: items ?? [],
    );
    final purchaseToken = await _getPurchaseToken(
      authToken: authToken,
      currency: _currency,
      orderID: orderID,
      amount: amountInCents,
      integrationId: _integrationCashID!,
      billingData: billingData ?? EasyPaymobBillingModel(),
    );

    final response = await _dio.post(
      'acceptance/payments/pay',
      data: {
        "source": {
          "identifier": phoneNumber,
          "subtype": "WALLET",
        },
        "payment_token": purchaseToken,
      },
    );
    final message = response.data['message'];
    if (message != null) {
      throw Exception(message);
    }
    String redirectUrl = response.data["redirect_url"].toString();

    if (context.mounted) {
      final response = await EasyPaymobIFrameWebView.show(
        context: context,
        redirectURL: redirectUrl,
        onPayment: onPayment,
      );
      return response;
    }
    return null;
  }

  /// Proceed to pay with only calling this function.
  Future<EasyPaymobResponse?> payWithKiosk(
      {
      /// Payment amount in cents EX: 20000 is an 200 EGP
      required String amountInCents,

      /// Optional Callback if you can use return result of pay function or use this callback
      void Function(EasyPaymobResponse response)? onPayment,

      /// list of json objects contains the contents of the purchase.
      List? items,

      /// The billing data related to the customer related to this payment.
      EasyPaymobBillingModel? billingData}) async {
    if (!_isInitialized) {
      throw Exception('PaymobPayment is not initialized call:`PaymobPayment.instance.initialize`');
    }

    if (_integrationCashID == null) {
      throw Exception('PaymobPayment is not initialized integrationKioskIID');
    }

    final authToken = await _getAuthToken();
    final orderID = await _addOrder(
      authToken: authToken,
      currency: _currency,
      amount: amountInCents,
      items: items ?? [],
    );
    final purchaseToken = await _getPurchaseToken(
      authToken: authToken,
      currency: _currency,
      orderID: orderID,
      amount: amountInCents,
      integrationId: _integrationKioskIID!,
      billingData: billingData ?? EasyPaymobBillingModel(),
    );

    final response = await _dio.post(
      'acceptance/payments/pay',
      data: {
        "source": {
          "identifier": "AGGREGATOR",
          "subtype": "AGGREGATOR",
        },
        "payment_token": purchaseToken,
      },
    );
    final message = response.data['message'];
    if (message != null) {
      throw Exception(message);
    }
    var data = response.data;

    if (data['id'] != null) {
      return EasyPaymobResponse(
        success: data['success'] == true,
        transactionID: data['id'].toString(),
        pending: data['pending'] == true,
        responseCode: data['data']['message'],
        message: data['data']['message'],
        type: 'Kiosk',
        billReference: data['data']["bill_reference"],
      );
    }

    return null;
  }

  /// get transaction status with only calling this function by transactionId.
  Future<EasyPaymobResponse?> getTransactionStatus({
    required String transactionId,
  }) async {
    if (!_isInitialized) {
      throw Exception('PaymobPayment is not initialized call:`PaymobPayment.instance.initialize`');
    }

    String token = await _getAuthToken();

    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

    final response = await _dio.request(
      'acceptance/transactions/$transactionId',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      return EasyPaymobResponse(
        success: response.data['success'] == true,
        transactionID: response.data['id'].toString(),
        pending: response.data['pending'] == true,
        responseCode: response.statusCode.toString(),
        message: response.data['data']['message'],
        type: response.data['source_data']['type'],
        billReference: response.data['data']["bill_reference"],
      );
    } else {
      throw Exception(response.statusMessage);
    }
  }
}
