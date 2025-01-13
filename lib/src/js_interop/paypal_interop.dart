import 'dart:js_interop';

@staticInterop
@JS('window')
class PayPalInterop {
  @JS()
  external static void renderPayPalButton(String tagName);

  @JS()
  external static void openPayPalWindow(
      double amount, String baseUrl, String payPalOrderId);

  @JS()
  external static set onPayPalWindowClose(JSFunction value);

  @JS()
  external static set onApprove(JSFunction value);

  @JS()
  external static set createOrder(JSFunction value);

  @JS()
  external static set onError(JSFunction value);
}
