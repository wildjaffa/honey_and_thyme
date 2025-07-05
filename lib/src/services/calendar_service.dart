import 'package:google_sign_in/google_sign_in.dart';
import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/models/calendar_auth_response.dart';
import 'package:honey_and_thyme/src/models/google_calendar.dart';
import '../models/calendar_settings.dart';
import 'api_service.dart';

class CalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static const List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/calendar.events',
  ];

  // Initialize Google Sign-In for web
  static Future<void> initialize() async {
    await _googleSignIn.initialize(
      clientId:
          '180260480727-av93h7aj2f3bddbjaem1f9gbu1r9v0ta.apps.googleusercontent.com',
    );
  }

  // Get current authentication state
  static Future<bool> hasValidTokens() async {
    try {
      final response = await ApiService.getRequest<BoolResult>(
        '/calendar/has-valid-tokens',
        (json) => BoolResult.fromJson(json),
      );
      return response.result ?? false;
    } catch (e) {
      return false;
    }
  }

  // For web, we don't use initiateGoogleSignIn directly
  // Instead, we use the renderButton widget and listen to authentication events
  static Future<String?> initiateGoogleSignIn() async {
    // This method is kept for compatibility but should not be used on web
    // The actual sign-in is handled by the renderButton widget
    print('Warning: initiateGoogleSignIn should not be called directly on web');
    return null;
  }

  // Get server auth code for a specific user (called after successful sign-in via events)
  static Future<String?> getServerAuthCode(GoogleSignInAccount user) async {
    try {
      // Request server authorization for the required scopes
      final GoogleSignInServerAuthorization? serverAuth =
          await user.authorizationClient.authorizeServer(_scopes);

      return serverAuth?.serverAuthCode;
    } catch (error) {
      print('Error getting server auth code: $error');
      return null;
    }
  }

  // Exchange auth code for tokens on the backend
  static Future<CalendarAuthResponse?> exchangeAuthCode(String authCode) async {
    try {
      final response = await ApiService.postRequest<CalendarAuthResponse>(
        '/calendar/exchange-auth-code',
        (json) => CalendarAuthResponse.fromJson(json),
        {'authCode': authCode},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get user's calendars
  static Future<List<GoogleCalendar>> getCalendars() async {
    try {
      final response = await ApiService.getRequest<GoogleCalendars>(
        '/calendar/list-calendars',
        (json) => GoogleCalendars.fromJson(json),
      );
      return response.values?.map((e) => e!).toList() ?? [];
    } catch (e) {
      print('Error fetching calendars: $e');
      rethrow;
    }
  }

  // Sign out from Google Calendar
  static Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await ApiService.postRequest<void>(
        '/calendar/sign-out',
        (json) {},
        {},
      );
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  static Future<CalendarSettings?> getCalendarSettings() async {
    try {
      final response = await ApiService.getRequest<CalendarSettings>(
        '/calendar/settings',
        (json) => CalendarSettings.fromJson(json),
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<CalendarSettings?> updateCalendarSettings(
      CalendarSettings settings) async {
    try {
      final response = await ApiService.postRequest<CalendarSettings>(
        '/calendar/settings',
        (json) => CalendarSettings.fromJson(json),
        settings,
      );
      return response;
    } catch (e) {
      return null;
    }
  }
}
