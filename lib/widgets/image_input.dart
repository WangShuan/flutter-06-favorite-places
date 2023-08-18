import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

import '../main.dart';

class ImageInput extends StatefulWidget {
  const ImageInput(this.selectedImg, {super.key});
  final void Function(File img) selectedImg;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImg;
  void onSelectedImg(bool isTakePicture) async {
    final ImagePicker picker = ImagePicker();
    final img = await picker.pickImage(source: isTakePicture ? ImageSource.camera : ImageSource.gallery, maxWidth: 600);
    if (img == null) {
      return;
    }
    setState(() {
      _selectedImg = File(img.path);
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(img.path);
    final copyImg = await _selectedImg!.copy('${appDir.path}/$filename');

    widget.selectedImg(copyImg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.3),
          border: Border.all(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (_selectedImg != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImg!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.primary.withOpacity(0.7)),
                  onPressed: () => onSelectedImg(true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍攝照片'),
                ),
                Text(
                  '或',
                  style: TextStyle(color: colorScheme.primary),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.primary.withOpacity(0.7)),
                  onPressed: () => onSelectedImg(false),
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('從相簿中選擇'),
                ),
              ],
            )
          ],
        ));
  }
}
