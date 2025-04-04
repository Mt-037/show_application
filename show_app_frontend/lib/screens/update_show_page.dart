// update_show_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/show.dart';

class UpdateShowPage extends StatefulWidget {
  final Show show;

  const UpdateShowPage({super.key, required this.show});

  @override
  State<UpdateShowPage> createState() => _UpdateShowPageState();
}

class _UpdateShowPageState extends State<UpdateShowPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.show.title);
    _descriptionController = TextEditingController(text: widget.show.description);
    _selectedCategory = widget.show.category;
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _updateShow() async {
    if (!mounted) return;

    setState(() => _isUpdating = true);

    try {
      var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${ApiConfig.baseUrl}/shows/${widget.show.id}')
      );

      request.fields.addAll({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
      });

      if (_imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', _imageFile!.path)
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true); // Retour avec succès
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la mise à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le Show')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(value: 'movie', child: Text('Film')),
                DropdownMenuItem(value: 'anime', child: Text('Anime')),
                DropdownMenuItem(value: 'serie', child: Text('Série')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 20),
            _buildImageSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateShow,
              child: _isUpdating
                  ? const CircularProgressIndicator()
                  : const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_imageFile != null)
          Image.file(_imageFile!, height: 200)
        else if (widget.show.imageUrl != null)
          Image.network('${ApiConfig.baseUrl}${widget.show.imageUrl}', height: 200)
        else

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galerie'),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ],
        ),
      ],
    );
  }
}