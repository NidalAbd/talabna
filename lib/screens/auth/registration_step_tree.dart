import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class RegistrationStepTree extends StatefulWidget {
  final Function(File?) onNext;

  const RegistrationStepTree({Key? key, required this.onNext}) : super(key: key);

  @override
  State<RegistrationStepTree> createState() => _RegistrationStepTreeState();
}

class _RegistrationStepTreeState extends State<RegistrationStepTree> {
  File? _selectedImage;

  List<String> defaultImages = [
    'assets/avatar.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
  ];

  String getRandomDefaultImage() {
    final random = Random();
    final index = random.nextInt(defaultImages.length);
    return defaultImages[index];
  }

  void _selectImageFromAsset(String imagePath) {
    setState(() {
      _selectedImage = null; // Clear the currently selected image

      // Check if the image path is one of the default images
      if (defaultImages.contains(imagePath)) {
        _selectedImage = null; // Set _selectedImage to null since it's a default image
      } else {
        // Image is selected from assets
        _selectedImage = null; // Set _selectedImage to null since it's an asset image
      }

      print('Selected image from asset: $_selectedImage');
    });
  }


  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _submitForm() {
    widget.onNext(_selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 120,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : AssetImage(getRandomDefaultImage()) as ImageProvider<Object>, // Specify ImageProvider<Object> type
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          children: List.generate(defaultImages.length, (index) {
            final imagePath = defaultImages[index];
            return GestureDetector(
              onTap: () => _selectImageFromAsset(imagePath),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
              ),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Select Image'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
