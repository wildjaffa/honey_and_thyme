import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/album.dart';

import '../../../utils/constants.dart';
import '../../services/image_service.dart';

class ImageUpload extends StatefulWidget {
  final Album album;
  final void Function()? onUploadComplete;
  const ImageUpload({
    super.key,
    required this.album,
    this.onUploadComplete,
  });

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  double _progress = 0.0;
  bool loading = false;

  void uploadImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result == null) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      for (final file in result.files) {
        await ImageService.uploadImage(
            widget.album.albumId!, file.bytes!, file.name);
        setState(() {
          _progress += 1 / result.files.length;
        });
      }
      if (widget.onUploadComplete != null) {
        widget.onUploadComplete!();
      }
    } catch (e) {
      const snackBar = SnackBar(
        content:
            Text('There was a problem uploading the images. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _progress = 0.0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: uploadImages,
          child: const Text('upload images'),
        ),
        if (loading)
          CircularProgressIndicator(
            backgroundColor: Colors.grey[300],
          ),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _progress,
            color: Constants.goldColor,
            backgroundColor:
                _progress != 0 ? Colors.grey[300] : Colors.transparent,
          ),
        )
      ],
    );
  }
}
