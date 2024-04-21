import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

class FormFile {
  final String fileName;
  final String formFieldName;
  final MediaType contentType;
  final Uint8List fileBytes;

  FormFile({
    required this.fileName,
    required this.formFieldName,
    required this.contentType,
    required this.fileBytes,
  });
}
