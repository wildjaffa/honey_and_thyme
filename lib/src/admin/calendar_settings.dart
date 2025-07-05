import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/google_calendar.dart';
import 'package:honey_and_thyme/src/services/calendar_service.dart';
import 'package:honey_and_thyme/src/widgets/web_google_sign_in_button.dart';
import '../../utils/snackbar_utils.dart';
import '../models/calendar_settings.dart';

class CalendarSettingsSelection extends StatefulWidget {
  const CalendarSettingsSelection({super.key});

  @override
  State<CalendarSettingsSelection> createState() =>
      _CalendarSettingsSelectionState();
}

class _CalendarSettingsSelectionState extends State<CalendarSettingsSelection> {
  bool _hasValidTokens = false;
  CalendarSettings? calendarSettings;
  bool _isLoading = false;
  List<GoogleCalendar>? _calendars;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authState = await CalendarService.hasValidTokens();
      setState(() {
        _hasValidTokens = authState;
      });
      if (!authState) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final calendars = await CalendarService.getCalendars();
      final settings = await CalendarService.getCalendarSettings();
      print('settings: ${settings?.preferredCalendarId}');
      setState(() {
        calendarSettings = settings;
        _calendars = calendars;
        _isLoading = false;
        // Set expanded to false if user has already selected a calendar
        _isExpanded = settings?.preferredCalendarId == null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showError(context, 'Failed to load calendar settings: $e');
    }
  }

  Future<void> _connectCalendar(String authCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Initiate Google Sign-In
      // final authCode = await CalendarService.initiateGoogleSignIn();

      if (authCode.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return; // User cancelled
      }

      // Step 2: Exchange auth code for tokens
      final newAuthState = await CalendarService.exchangeAuthCode(authCode);
      if (newAuthState == null || !newAuthState.success) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Step 3: Get user's calendars
      final calendars = await CalendarService.getCalendars();

      setState(() {
        _hasValidTokens = true;
        _calendars = calendars;
        _isLoading = false;
      });

      showSuccess(context, 'Calendar connected successfully!');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showError(context, 'Failed to connect calendar: $e');
    }
  }

  Future<void> _disconnectCalendar() async {
    try {
      await CalendarService.signOut();
      setState(() {
        _hasValidTokens = false;
      });
      showSuccess(context, 'Calendar disconnected successfully!');
    } catch (e) {
      showError(context, 'Failed to disconnect calendar: $e');
    }
  }

  Future<void> _selectCalendar(GoogleCalendar calendar) async {
    try {
      if (calendarSettings == null) {
        return;
      }
      calendarSettings = calendarSettings!.copyWith(
        preferredCalendarId: calendar.id,
      );
      await CalendarService.updateCalendarSettings(calendarSettings!);

      // Update the local state
      final updatedCalendars = _calendars!.map((cal) {
        return cal.copyWith(selected: cal.id == calendar.id);
      }).toList();

      setState(() {
        _calendars = updatedCalendars;
      });

      showSuccess(context,
          'Calendar "${calendar.summary}" selected for publishing events!');
    } catch (e) {
      showError(context, 'Failed to select calendar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Google Calendar Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              if (_hasValidTokens) ...[
                // Connected state
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    // Expanded(
                    //   child: Text(
                    //     'Connected as: $_userEmail',
                    //     style: const TextStyle(fontWeight: FontWeight.w500),
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: _disconnectCalendar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Calendar selection
                if (_calendars != null && _calendars!.isNotEmpty) ...[
                  const Text(
                    'Select Calendar for Publishing Events:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...(_calendars!.map(
                    (calendar) => ListTile(
                      leading: Icon(
                        calendar.selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: calendar.selected ? Colors.blue : null,
                      ),
                      title: Text(calendar.summary),
                      subtitle: calendar.primary
                          ? const Text('Primary Calendar')
                          : null,
                      onTap: () => _selectCalendar(calendar),
                    ),
                  )),
                ] else ...[
                  const Text('No calendars found.'),
                ],
              ] else ...[
                // Not connected state
                const Text(
                  'Connect your Google Calendar to automatically publish photo shoot events.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                WebGoogleSignInButton(
                  onAuthCodeReceived: (authCode) {
                    _connectCalendar(authCode);
                  },
                ),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //         onPressed: _isConnecting ? null : _connectCalendar,
                //         icon: _isConnecting
                //             ? const SizedBox(
                //                 width: 16,
                //                 height: 16,
                //                 child: CircularProgressIndicator(strokeWidth: 2),
                //               )
                //             : const Icon(Icons.calendar_today),
                //         label: Text(
                //             _isConnecting ? 'Connecting...' : 'Connect Calendar'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.blue,
                //           foregroundColor: Colors.white,
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //         ),
                //       ),
                // ),
              ],
            ] else if (_hasValidTokens &&
                calendarSettings?.preferredCalendarId != null) ...[
              // Show summary when collapsed and calendar is selected
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calendar connected and configured',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
