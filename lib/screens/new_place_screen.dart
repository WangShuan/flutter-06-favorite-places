import 'dart:io';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../widgets/location_input.dart';
import '../widgets/image_input.dart';

class NewPlaceScreen extends StatefulWidget {
  const NewPlaceScreen({super.key});

  @override
  State<NewPlaceScreen> createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends State<NewPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    String name = '';
    PlaceLocation? local;
    File? image;

    void submitForm() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (image == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請拍攝照片或從相簿中選取圖片。')));
          return;
        }
        if (local == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請點擊獲取當前位置或從地圖中選取地點。')));
          return;
        }
        Navigator.of(context).pop(
          Place(title: name, image: image!, location: local!),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('新增地點')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '地點名稱',
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLength: 8,
                  validator: (val) => val == null || val.isEmpty || val.trim().length < 2 ? 'Name must be at least 2 characters.' : null,
                  onSaved: (newValue) => name = newValue!,
                ),
                const SizedBox(height: 16),
                ImageInput((img) => image = img),
                const SizedBox(height: 16),
                LocationInput((lat, long, address) => local = PlaceLocation(lat: lat, lng: long, address: address)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: submitForm,
                    child: const Text('Submit'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
