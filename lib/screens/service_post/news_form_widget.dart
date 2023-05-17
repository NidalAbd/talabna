import 'package:flutter/material.dart';

class NewsPostForm extends StatefulWidget {
  const NewsPostForm({Key? key, required this.onPostSubmitted}) : super(key: key);
  final Function(String text, String? mediaType) onPostSubmitted;

  @override
  State<NewsPostForm> createState() => _NewsPostFormState();
}

class _NewsPostFormState extends State<NewsPostForm> {
  final TextEditingController _textEditingController = TextEditingController();
  String? _selectedMediaType;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add New Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Post Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMediaType,
              onChanged: (value) {
                setState(() {
                  _selectedMediaType = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Media Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: 'photo',
                  child: Text('Photo'),
                ),
                DropdownMenuItem<String>(
                  value: 'video',
                  child: Text('Video'),
                ),
                DropdownMenuItem<String>(
                  value: 'sound',
                  child: Text('Sound'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final text = _textEditingController.text;
                final mediaType = _selectedMediaType;
                widget.onPostSubmitted(text, mediaType);
                _textEditingController.clear();
                setState(() {
                  _selectedMediaType = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
