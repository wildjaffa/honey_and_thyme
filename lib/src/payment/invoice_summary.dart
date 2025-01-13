import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';
import 'package:intl/intl.dart';

class InvoiceSummary extends StatelessWidget {
  final PhotoShoot photoShoot;

  const InvoiceSummary({super.key, required this.photoShoot});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final totalPaid = photoShoot.price! - photoShoot.paymentRemaining!;
      var remainder = photoShoot.paymentRemaining!;
      if (remainder < 0) {
        remainder = 0;
      }
      final hasDiscount =
          photoShoot.discount != null && photoShoot.discount! > 0;
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Text(
              "Invoice Summary",
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 30,
              ),
            ),
            const Text(
              'Deposit is non-refundable and will not be returned if the client misses for any reason. Balance is due the day of the shoot and must be paid in order to receive photos. If the client arrives late, they may be subject to a shorter photo shoot or rescheduling. Turn around time is typically two weeks but could be longer during busy seasons. Honey+Thyme reserves the right to use any and all photos for marketing purposes. By inquiring about our services or doing business with us, you are giving your consent to receive notifications and messages (e-mail or text) regarding our promotions or services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 300,
              child: Table(
                children: [
                  TableRow(
                    children: [
                      const Text(
                        "Invoice for:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        photoShoot.responsiblePartyName!,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Service:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        photoShoot.nameOfShoot!,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Date of Service:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        DateFormat.yMd()
                            .add_jm()
                            .format(photoShoot.dateTimeUtc!.toLocal()),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Total Billed:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "\$${photoShoot.price}",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  if (hasDiscount)
                    TableRow(
                      children: [
                        const Text(
                          "Discount:",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "${photoShoot.discountName} \$${photoShoot.discount}",
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  TableRow(
                    children: [
                      const Text(
                        "Total Paid:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "\$$totalPaid",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Total Remaining:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "\$$remainder",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text(
                        "Payment Status:",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        remainder == 0 ? "Paid" : "Unpaid",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
