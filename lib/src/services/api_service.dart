import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:honey_and_thyme/src/models/form_file.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class ApiService {
  // https://mindfulmeasuresapi.playable.online/
  // static const url = 'mindfulmeasuresapi.playable.online';
  // static const url = 'jensenpro.duckdns.org:8567';
  static const url = 'localhost:6363';
  // static const url = '10.0.2.2:44364';

  static Uri getUri(String baseUrl,
      [String route = '', Map<String, dynamic>? queryParameters]) {
    return Uri.http(baseUrl, route, queryParameters);
  }

  static Future<T> getRequest<T>(
      String route, T Function(Map<String, dynamic> json) parser,
      {Map<String, String>? queryParameters}) async {
    final client = RetryClient(http.Client());
    final uri = getUri(url, route, queryParameters);
    try {
      final response = await client.get(uri, headers: await _getHeaders());
      if (response.statusCode > 300) {
        throw 'Bad Response ${response.statusCode}';
      }
      final stringIfied = utf8.decode(response.bodyBytes);
      final parsed = jsonDecode(stringIfied);
      final object = parser(parsed);
      return object;
    } finally {
      client.close();
    }
  }

  static Future<T> postRequest<T>(
      String route, T Function(dynamic json) parser, dynamic body) async {
    final uri = getUri(url, route);
    final headers = await _getHeaders();
    headers.addEntries({
      'Content-Type': 'application/json; charset=UTF-8',
    }.entries);
    final client = RetryClient(http.Client());
    try {
      final response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode > 300) {
        throw 'Bad Response ${response.statusCode}';
      }
      final stringIfied = utf8.decode(response.bodyBytes);
      final parsed = jsonDecode(stringIfied);
      final object = parser(parsed);
      return object;
    } finally {
      client.close();
    }
  }

  static Future<T> deleteRequest<T>(
      String route, T Function(Map<String, dynamic> json) parser,
      {Map<String, String>? queryParameters}) async {
    final uri = getUri(url, route, queryParameters);
    final client = RetryClient(http.Client());
    try {
      final response = await client.delete(uri, headers: await _getHeaders());
      if (response.statusCode > 300) {
        throw 'Bad Response ${response.statusCode}';
      }
      final stringIfied = utf8.decode(response.bodyBytes);
      final parsed = jsonDecode(stringIfied);
      final object = parser(parsed);
      return object;
    } finally {
      client.close();
    }
  }

  static Future<T> multiPartFormRequest<T>(
      String route,
      T Function(Map<String, dynamic> json) parser,
      Map<String, String> additionalFields,
      List<FormFile> files) async {
    final request = http.MultipartRequest('POST', getUri(url, route));

    for (final field in additionalFields.entries) {
      request.fields[field.key] = field.value;
    }

    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          file.formFieldName,
          file.fileBytes,
          filename: file.fileName,
          contentType: file.contentType,
        ),
      );
    }
    request.headers.addAll(await _getHeaders());
    final response = await request.send();
    final bodyBytes = await response.stream.toBytes();
    final stringIfied = utf8.decode(bodyBytes);
    final parsed = jsonDecode(stringIfied);
    final object = parser(parsed);
    return object;
  }

  static Future<Map<String, String>> _getHeaders() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return {};
    }
    var idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    return {
      'Authorization': 'Bearer ${idToken!}',
    };
  }
}
