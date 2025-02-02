class BookingRequest {
  String? name;
  String? email;
  int? numberOfPeople;
  String? sessionLength;
  String? occasion;
  String? location;
  String? questions;

  BookingRequest({
    this.name,
    this.email,
    this.numberOfPeople,
    this.sessionLength,
    this.occasion,
    this.location,
    this.questions,
  });

  BookingRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    numberOfPeople = json['numberOfPeople'];
    sessionLength = json['sessionLength'];
    occasion = json['occasion'];
    location = json['location'];
    questions = json['questions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['numberOfPeople'] = numberOfPeople;
    data['sessionLength'] = sessionLength;
    data['occasion'] = occasion;
    data['location'] = location;
    data['questions'] = questions;
    return data;
  }
}
