abstract class Parsable {
  factory Parsable.fromJson(dynamic json) {
    throw UnimplementedError('Parsable.fromJson is not implemented');
  }
  Map<String, dynamic> toJson();
}
