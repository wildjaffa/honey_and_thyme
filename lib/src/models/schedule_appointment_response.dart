import 'photo_shoot.dart';

class ScheduleAppointmentResponse {
  final bool success;
  final PhotoShoot? photoShoot;
  final BookingError? error;

  const ScheduleAppointmentResponse({
    required this.success,
    this.photoShoot,
    this.error,
  });

  factory ScheduleAppointmentResponse.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw FormatException(
          'Expected Map<String, dynamic>, got ${json.runtimeType}');
    }

    return ScheduleAppointmentResponse(
      success: json['success'] ?? false,
      photoShoot: json['photoShoot'] != null
          ? PhotoShoot.fromJson(json['photoShoot'])
          : null,
      error:
          json['error'] != null ? BookingError.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'photoShoot': photoShoot?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class BookingError {
  final String code;
  final String message;
  final String? details;

  const BookingError({
    required this.code,
    required this.message,
    this.details,
  });

  factory BookingError.fromJson(Map<String, dynamic> json) {
    return BookingError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (details != null) 'details': details,
    };
  }

  @override
  String toString() {
    return 'BookingError(code: $code, message: $message, details: $details)';
  }
}
