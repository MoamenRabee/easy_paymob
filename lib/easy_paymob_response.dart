part of 'easy_payment.dart';

class EasyPaymobResponse {
  bool success;
  bool pending;
  String? transactionID;
  String? responseCode;
  String? message;
  String? type;
  int? billReference;

  EasyPaymobResponse({
    this.transactionID,
    required this.success,
    required this.pending,
    this.responseCode,
    this.message,
    this.type,
    this.billReference,
  });

  factory EasyPaymobResponse.fromJson(Map<String, dynamic> json) {
    return EasyPaymobResponse(
      success: json['success'] == 'true',
      pending: json['pending'] == 'true',
      transactionID: json['id'].toString(),
      message: json['data.message'],
      type: json['source_data.type'],
      responseCode: json['txn_response_code'],
    );
  }
}
