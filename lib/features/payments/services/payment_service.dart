import '../../../core/network/api_client.dart';

class PaymentService {
  final ApiClient _api;
  PaymentService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<Uri> createCheckout(String orderId) async {
    final result = await _api.request('POST', '/checkout', {'orderId': orderId});
    final uri = Uri.parse(result['url'] as String);
    if (uri.scheme != 'https' || uri.host != 'checkout.stripe.com') {
      throw const ApiFailure('رابط الدفع غير صالح.');
    }
    return uri;
  }

  Future<bool> isPaid(String orderId) async {
    final result = await _api.request('GET', '/orders/${Uri.encodeComponent(orderId)}');
    return result['paid'] == true;
  }
}
