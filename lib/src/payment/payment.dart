import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/js_interop/paypal_interop.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:web/web.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  static const route = '/payment';
  static double paymentAmount = 100.0;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance
  //       .addPostFrameCallback((_) => PayPalInterop.renderPayPalButton());
  // }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.pricing,
      child: SingleChildScrollView(
        child: Center(
          child: HtmlElementView.fromTagName(
            key: const ValueKey('paypal-button'),
            tagName: 'paypal-button',
            isVisible: true,
            onElementCreated: (element) async {
              (element as HTMLElement).id = 'paypal-button-container';
              await Future.delayed(const Duration(milliseconds: 100));
              PayPalInterop.renderPayPalButton('paypal-button');
            },
          ),
        ),
      ),
    );
  }
}
