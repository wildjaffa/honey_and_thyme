import 'package:honey_and_thyme/src/models/parsable.dart';

class BookAppointmentRequest implements Parsable {
  String? photoShootId;
  String? name;
  String? email;

  BookAppointmentRequest({
    this.photoShootId,
    this.name,
    this.email,
  });

  BookAppointmentRequest.fromJson(Map<String, dynamic> json) {
    photoShootId = json['photoShootId'];
    name = json['name'];
    email = json['email'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'photoShootId': photoShootId,
      'name': name,
      'email': email,
    };
  }
}
