import 'dart:math';

import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/admin.dart';

import '../../models/album.dart';
import '../../services/album_service.dart';

class AlbumForm extends StatefulWidget {
  final Album album;
  final void Function()? onAlbumSaved;
  const AlbumForm({
    super.key,
    required this.album,
    this.onAlbumSaved,
  });

  @override
  State<AlbumForm> createState() => _AlbumFormState();
}

class _AlbumFormState extends State<AlbumForm> {
  final albumFormKey = GlobalKey<FormState>();

  bool isPublic = false;

  void submit() async {
    if (!albumFormKey.currentState!.validate()) {
      return;
    }
    // remove all non-alphanumeric characters except -
    RegExp rgx = RegExp("[^a-zA-Z0-9 -]");
    widget.album.urlName = widget.album.name!
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(rgx, '');
    widget.album.isPublic = isPublic == true;

    final newAlbum = widget.album.id == null
        ? await AlbumService.createAlbum(widget.album)
        : await AlbumService.updateAlbum(widget.album);
    final snackBar = SnackBar(
      content: Text(
          'Album ${newAlbum.name} saved, available at ${newAlbum.urlName}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if (widget.onAlbumSaved != null) {
      widget.onAlbumSaved!();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.album.id == null) {
      widget.album.isPublic = false;
      widget.album.password = generatePassword(6);
    }
  }

  String generatePassword(int length) {
    var password = '';
    var random = Random.secure();
    for (var i = 0; i < length; i++) {
      password += random.nextInt(10).toString();
    }
    return password;
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Album'),
          content: const Text('Are you sure you want to delete this album?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await AlbumService.deleteAlbum(widget.album.albumId!);
                const snackBar = SnackBar(
                  content: Text('Album deleted'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.pushNamedAndRemoveUntil(
                    context, AdminView.route, (route) => route.isFirst);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Form(
            key: albumFormKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.album.name,
                  decoration: const InputDecoration(
                    labelText: 'Album Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an album name';
                    }
                    return null;
                  },
                  onChanged: (value) => widget.album.name = value,
                ),
                TextFormField(
                  initialValue: widget.album.description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onChanged: (value) => widget.album.description = value,
                ),
                TextFormField(
                    initialValue: widget.album.password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        widget.album.password = null;
                      }
                      widget.album.password = value;
                    }),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Is Public'),
                    ),
                    Checkbox(
                      value: widget.album.isPublic,
                      onChanged: (value) {
                        widget.album.isPublic = value;
                        setState(() {
                          isPublic = value!;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: submit,
                    child: const Text('Submit'),
                  ),
                ),
                if (widget.album.albumId != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: confirmDelete,
                      child: const Text('Delete'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
