import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerField extends StatefulWidget {
  final Function(XFile?) onImagePicked;

  const ImagePickerField({super.key, required this.onImagePicked});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
      widget.onImagePicked(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text("Pick Image"),
        ),
        const SizedBox(width: 16),
        _pickedImage != null
            ? Image.file(
                File(_pickedImage!.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : const Text("No image selected"),
      ],
    );
  }
}