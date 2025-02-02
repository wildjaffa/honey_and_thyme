class ContactRequest {
  String? email;
  String? message;

  ContactRequest({this.email, this.message});

  ContactRequest.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['message'] = message;
    return data;
  }
}
