import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';

class AddEditCarScreen extends StatefulWidget {
  final Map? car;
  const AddEditCarScreen({super.key, this.car});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final typeCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  File? imageFile;
  String? existingImage;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      typeCtrl.text = widget.car!['type'];
      priceCtrl.text = widget.car!['price_per_day'];
      descCtrl.text = widget.car!['description'] ?? '';
      existingImage = widget.car!['image'];
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_image.php'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final res = await request.send();
    final body = await res.stream.bytesToString();
    return json.decode(body)['filename'];
  }

  Future<void> saveCar() async {
    // ===== FORM VALIDATION =====
    if (!_formKey.currentState!.validate()) return;

    // ===== IMAGE VALIDATION =====
    if (imageFile == null && existingImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a vehicle image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => saving = true);

    String? imageName = existingImage;
    if (imageFile != null) {
      imageName = await uploadImage(imageFile!);
    }

    final data = {
      'type': typeCtrl.text.trim(),
      'price_per_day': double.parse(priceCtrl.text),
      'description': descCtrl.text.trim(),
      'image': imageName,
      if (widget.car != null) 'id': widget.car!['id'],
    };

    if (widget.car == null) {
      await http.post(
        Uri.parse('$baseUrl/cars.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
    } else {
      await http.put(
        Uri.parse('$baseUrl/cars.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.car == null
              ? 'Vehicle added successfully'
              : 'Vehicle updated successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            if (label == 'Daily Price' &&
                double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.car != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Image Picker =====
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey.shade200,
                    image: imageFile != null
                        ? DecorationImage(
                            image: FileImage(imageFile!),
                            fit: BoxFit.cover,
                          )
                        : existingImage != null
                            ? DecorationImage(
                                image: NetworkImage(
                                  '$imagesUrl/$existingImage',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: imageFile == null && existingImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 40),
                            SizedBox(height: 6),
                            Text('Tap to upload vehicle image'),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              _inputField(
                controller: typeCtrl,
                label: 'Car Type',
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: priceCtrl,
                label: 'Daily Price',
                type: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: descCtrl,
                label: 'Description',
                maxLines: 3,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saving ? null : saveCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit
                        ? const Color.fromARGB(255, 19, 36, 79)
                        : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit
                          ? 'Update Vehicle'
                          : 'Add Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
