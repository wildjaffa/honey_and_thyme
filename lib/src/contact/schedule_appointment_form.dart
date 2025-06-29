import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/constants.dart';
import '../models/schedule_appointment_request.dart';
import '../models/photo_shoot.dart';
import '../payment/invoice.dart';
import '../services/photo_shoot_service.dart';
import '../widgets/honey_input_field.dart';
import '../widgets/loading_button.dart';

class ScheduleAppointmentForm extends StatefulWidget {
  final PhotoShoot photoShoot;
  final Function(PhotoShoot) onSubmit;
  final Function(PhotoShoot) onCancel;
  const ScheduleAppointmentForm({
    super.key,
    required this.photoShoot,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<ScheduleAppointmentForm> createState() =>
      _ScheduleAppointmentFormState();
}

class _ScheduleAppointmentFormState extends State<ScheduleAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _submitFocusNode = FocusNode();
  final _cancelFocusNode = FocusNode();
  final _payNowFocusNode = FocusNode();
  final _payLaterFocusNode = FocusNode();
  String? _reservationCode;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _submitFocusNode.dispose();
    _cancelFocusNode.dispose();
    _payNowFocusNode.dispose();
    _payLaterFocusNode.dispose();
    super.dispose();
  }

  Future<void> bookAppointment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await PhotoShootService.scheduleAppointment(
        ScheduleAppointmentRequest(
          photoShootId: widget.photoShoot.photoShootId,
          name: widget.photoShoot.responsiblePartyName,
          email: widget.photoShoot.responsiblePartyEmailAddress,
        ),
      );

      if (response.success && response.photoShoot != null) {
        setState(() {
          _isSuccess = true;
          _reservationCode = response.photoShoot?.reservationCode;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.error != null) {
        // Handle specific error cases based on error code
        String errorMessage = response.error!.message;

        switch (response.error!.code) {
          case 'APPOINTMENT_ALREADY_BOOKED':
            errorMessage =
                'This appointment has already been booked by another client. Please select a different time.';
            break;
          case 'APPOINTMENT_NOT_FOUND':
            errorMessage =
                'This appointment is no longer available. Please refresh the page and try again.';
            break;
          case 'APPOINTMENT_EXPIRED':
            errorMessage =
                'This appointment time has passed. Please select a future time.';
            break;
          case 'INVALID_EMAIL':
            errorMessage = 'Please enter a valid email address.';
            break;
          default:
            errorMessage = response.error!.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        // Fallback for unexpected responses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Sorry, there was an issue booking your appointment. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      String errorMessage =
          'Network connection issue. Please check your internet connection and try again.';

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Network connection issue. Please check your internet connection and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToInvoice() {
    Navigator.pushNamed(
      context,
      '${Invoice.route}?id=$_reservationCode',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isSuccess ? _buildSuccessContent() : _buildFormContent(),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return FocusScope(
      autofocus: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 24),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text:
                      'Your appointment time has been requested. Your appointment will NOT be considered confirmed until your deposit is paid which you can do now, or by clicking the link in the email we have sent you. ',
                ),
                const TextSpan(
                  text: '\n\n'
                      'If deposit is not paid within 30 minutes, your time slot will be released for other clients.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Focus(
            focusNode: _payNowFocusNode,
            child: LoadingButton(
              text: 'Pay Now',
              isLoading: false,
              onPressed: navigateToInvoice,
              backgroundColor: Constants.goldColor,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Focus(
            focusNode: _payLaterFocusNode,
            child: TextButton(
              onPressed: () {
                widget.onCancel(widget.photoShoot);
              },
              child: const Text('Pay Later'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return FocusScope(
      autofocus: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Photo shoot details section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Constants.pinkColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    widget.photoShoot.nameOfShoot ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.photoShoot.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.photoShoot.description ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SelectableText(
                          widget.photoShoot.location ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      SelectableText(
                        DateFormat('dd/MM/yyyy')
                            .add_jm()
                            .format(widget.photoShoot.dateTimeUtc!.toLocal()),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(
                        'Price: \$${widget.photoShoot.price.toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SelectableText(
                        'Deposit: \$${widget.photoShoot.deposit.toString()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact details section
            const Text(
              'Contact Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            HoneyInputField(
              width: double.infinity,
              initialValue: '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              label: 'Name',
              onChanged: (value) {
                widget.photoShoot.responsiblePartyName = value;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_emailFocusNode);
              },
              autofocus: true,
              focusNode: _nameFocusNode,
            ),

            const SizedBox(height: 16),

            HoneyInputField(
              width: double.infinity,
              initialValue: '',
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Email is required';
                }
                return null;
              },
              label: 'Email',
              onChanged: (value) {
                widget.photoShoot.responsiblePartyEmailAddress = value;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  bookAppointment();
                } else {
                  FocusScope.of(context).requestFocus(_submitFocusNode);
                }
              },
              focusNode: _emailFocusNode,
            ),

            const SizedBox(height: 32),

            // Buttons section
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Focus(
                  focusNode: _submitFocusNode,
                  child: LoadingButton(
                    text: 'Submit',
                    isLoading: _isLoading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      bookAppointment();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Focus(
                  focusNode: _cancelFocusNode,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            widget.onCancel(widget.photoShoot);
                          },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
