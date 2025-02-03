import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/js_interop/paypal_interop.dart';
import 'package:honey_and_thyme/src/models/create_photo_shoot_payment_request.dart';
import 'package:honey_and_thyme/src/models/create_photo_shoot_payment_response.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/payment/invoice_summary.dart';
import 'package:honey_and_thyme/src/services/photo_shoot_service.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:honey_and_thyme/src/widgets/dollar_input_field.dart';

import '../../utils/constants.dart';
import '../models/enums/payment_processors.dart';
import '../models/photo_shoot.dart';
import '../models/photo_shoot_payment_capture_request.dart';
import '../widgets/app_footer.dart';

class Invoice extends StatefulWidget {
  final String photoShootId;
  const Invoice({
    super.key,
    required this.photoShootId,
  });

  static const String route = '/invoice';

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  late Future<PhotoShoot> photoShoot =
      PhotoShootService.fetchPhotoShoot(widget.photoShootId);

  final inputStyle = GoogleFonts.imFellEnglish(
    color: Colors.black,
    fontSize: 18,
  );

  InvoiceStatus status = InvoiceStatus.selecting;
  double tip = 0.0;

  double amountToBePaid = 0.0;

  String errorString = '';

  CreatePhotoShootPaymentResponse? order;

  @override
  void initState() {
    super.initState();
    PayPalInterop.onApprove = onApprove.toJS;
    PayPalInterop.onError = onError.toJS;
    PayPalInterop.onPayPalWindowClose = payPalWindowClosed.toJS;
  }

  void onError(String error) {
    setState(() {
      status = InvoiceStatus.error;
      errorString = error;
    });
  }

  void payPalWindowClosed() {
    if (status != InvoiceStatus.awaitingPaypal) {
      return;
    }
    setState(() {
      status = InvoiceStatus.selecting;
    });
  }

  void onApprove(String orderId) async {
    if (order == null) {
      setState(() {
        status = InvoiceStatus.declined;
        errorString =
            'There was an issue communicating with PayPal, but your card was not charged. Please try again.';
      });
      return;
    }
    setState(() {
      status = InvoiceStatus.capturing;
    });
    final request = PhotoShootPaymentCaptureRequest(
      amountToBeCharged: amountToBePaid,
      externalOrderId: orderId,
      paymentProcessor: PaymentProcessors.paypal,
      photoShootId: widget.photoShootId,
      invoiceId: order!.invoiceId,
    );
    final response = await PhotoShootService.capturePhotoShootPayment(request);

    if (response.isSuccess != true && response.shouldTryAgain == false) {
      setState(() {
        status = InvoiceStatus.error;
        errorString =
            "There was a problem communicating with PayPal please reach out to Honey and Thyme to confirm you payment was completed.";
      });
      return;
    } else if (response.isSuccess != true && response.shouldTryAgain == true) {
      setState(() {
        status = InvoiceStatus.declined;
        errorString =
            "There was a problem charging your card, please try again.";
      });
      return;
    }

    setState(() {
      photoShoot = PhotoShootService.fetchPhotoShoot(widget.photoShootId);
      status = InvoiceStatus.success;
    });
  }

  void payDeposit() async {
    final shoot = await photoShoot;
    setState(() {
      amountToBePaid = shoot.deposit!;
      status = InvoiceStatus.payingDeposit;
    });
  }

  Future<void> createPayment() async {
    setState(() {
      status = InvoiceStatus.creatingOrder;
    });
    final shoot = await photoShoot;
    final createRequest = CreatePhotoShootPaymentRequest(
      amount: amountToBePaid,
      photoShootId: widget.photoShootId,
      description: shoot.nameOfShoot,
      paymentProcessorEnum: PaymentProcessors.paypal,
    );
    order = await PhotoShootService.createPhotoShootPayment(createRequest);
    if (order!.isSuccess != true || order!.processorOrderId == null) {
      setState(() {
        status = InvoiceStatus.error;
      });
      return;
    }
    setState(() {
      status = InvoiceStatus.awaitingPaypal;
    });
    PayPalInterop.openPayPalWindow(
        amountToBePaid, '', order!.processorOrderId!);
  }

  void payTotal() async {
    final shoot = await photoShoot;
    setState(() {
      status = InvoiceStatus.payingTotal;
      amountToBePaid = shoot.paymentRemaining!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.home,
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: photoShoot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                status == InvoiceStatus.capturing) {
              return const Padding(
                padding: EdgeInsets.all(50.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Text(
                  'There was an issue loading the invoice, please try again later.');
            }

            if (status == InvoiceStatus.awaitingPaypal) {
              return LayoutBuilder(builder: (context, constraints) {
                double width = 500;
                if (constraints.maxWidth < 600) {
                  width = constraints.maxWidth - 50;
                }
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: SizedBox(
                      width: width,
                      child: const Text(
                        'Please complete your payment in the PayPal window.',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              });
            }

            final photoShoot = snapshot.data as PhotoShoot;

            final totalPaid = photoShoot.price! - photoShoot.paymentRemaining!;

            final depositPaid = photoShoot.deposit! <= totalPaid;

            final paymentNeeded = photoShoot.paymentRemaining! > 0;

            if (status == InvoiceStatus.error) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.warning,
                        color: Constants.goldColor,
                        size: 40,
                      ),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(fontSize: 32),
                      ),
                      Text(
                        errorString,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (status == InvoiceStatus.declined) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.credit_card_off,
                        color: Constants.goldColor,
                        size: 40,
                      ),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(fontSize: 32),
                      ),
                      Text(
                        errorString,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              status = InvoiceStatus.selecting;
                              errorString = '';
                            });
                          },
                          child: const Text('Try Again'))
                    ],
                  ),
                ),
              );
            }

            if (status == InvoiceStatus.success) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.check_circle,
                        color: Constants.goldColor,
                        size: 40,
                      ),
                      const Text(
                        'Your payment was successful!',
                        style: TextStyle(fontSize: 32),
                      ),
                      if (paymentNeeded)
                        Text(
                          'You have a remaining balance of \$${photoShoot.paymentRemaining} due the day of your shoot which you can pay anytime by returning to this page.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      const Text(
                        'Thank you for your business!',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                InvoiceSummary(photoShoot: photoShoot),
                const SizedBox(height: 20),
                if (status == InvoiceStatus.selecting && paymentNeeded)
                  SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!depositPaid)
                          ElevatedButton(
                            onPressed: payDeposit,
                            child: const Text('Pay Deposit'),
                          ),
                        ElevatedButton(
                          onPressed: payTotal,
                          child: const Text('Pay Total'),
                        ),
                      ],
                    ),
                  ),
                if (status == InvoiceStatus.payingTotal)
                  SizedBox(
                    width: 300,
                    child: DollarInputField(
                      initialValue: tip,
                      onChanged: (p0) {
                        setState(() {
                          tip = p0;
                          amountToBePaid = photoShoot.paymentRemaining! + tip;
                        });
                      },
                      label: 'Tip never expected, always a nice surprise',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                if (status == InvoiceStatus.payingTotal ||
                    status == InvoiceStatus.payingDeposit) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: createPayment,
                    child: Text('Confirm Pay \$$amountToBePaid'),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      status = InvoiceStatus.selecting;
                    }),
                    child: const Text('Cancel'),
                  ),
                ],
                if (status == InvoiceStatus.creatingOrder)
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(
                  height: 20,
                ),
                LayoutBuilder(builder: (context, constraints) {
                  double width = 500;
                  if (constraints.maxWidth < 600) {
                    width = constraints.maxWidth - 50;
                  }
                  return SizedBox(
                    width: width,
                    child: const Text(
                      'Deposit is non-refundable and will not be returned if the client misses for any reason. Balance is due the day of the shoot and must be paid in order to receive photos. If the client arrives late, they may be subject to a shorter photo shoot or rescheduling. Turn around time is typically two weeks but could be longer during busy seasons. Honey+Thyme reserves the right to use any and all photos for marketing purposes. By inquiring about our services or doing business with us, you are giving your consent to receive notifications and messages (e-mail or text) regarding our promotions or services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }),
                const AppFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum InvoiceStatus {
  selecting,
  payingDeposit,
  payingTotal,
  creatingOrder,
  capturing,
  error,
  success,
  awaitingPaypal,
  declined,
}
