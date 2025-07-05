import 'parsable.dart';

class CalendarAuthResponse implements Parsable {
  final bool success;
  final String? errorMessage;
  final bool hasValidTokens;

  CalendarAuthResponse({
    required this.success,
    this.errorMessage,
    required this.hasValidTokens,
  });

  factory CalendarAuthResponse.fromJson(Map<String, dynamic> json) {
    return CalendarAuthResponse(
      success: json['success'],
      errorMessage: json['ErrorMessage'],
      hasValidTokens: json['HasValidTokens'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'ErrorMessage': errorMessage,
      'HasValidTokens': hasValidTokens,
    };
  }
}
