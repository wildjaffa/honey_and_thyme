class ContactRequest {
  String? email;
  String? message;

  ContactRequest({this.email, this.message});

  ContactRequest.fromJson(Map<String, dynamic> json) {
    email = json['Email'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Email'] = email;
    data['Message'] = message;
    return data;
  }
}
