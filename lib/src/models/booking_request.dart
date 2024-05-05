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
    name = json['Name'];
    email = json['Email'];
    numberOfPeople = json['NumberOfPeople'];
    sessionLength = json['SessionLength'];
    occasion = json['Occasion'];
    location = json['Location'];
    questions = json['Questions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Email'] = email;
    data['NumberOfPeople'] = numberOfPeople;
    data['SessionLength'] = sessionLength;
    data['Occasion'] = occasion;
    data['Location'] = location;
    data['Questions'] = questions;
    return data;
  }
}
