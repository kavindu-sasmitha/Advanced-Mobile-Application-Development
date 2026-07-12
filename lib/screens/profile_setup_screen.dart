import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/user_profile.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();

  DateTime? _birthday;
  String? _gender;
  File? _pickedImage;
  bool _saving = false;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthday = date);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please pick your birthday')));
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select gender')));
      return;
    }

    setState(() => _saving = true);
    try {
      final user = _authService.currentUser!;
      String picUrl = user.photoURL ?? '';
      if (_pickedImage != null) {
        picUrl = await _storageService.uploadProfilePic(user.uid, _pickedImage!);
      }

      final profile = UserProfile(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        email: user.email ?? '',
        age: int.parse(_ageCtrl.text.trim()),
        country: _countryCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        birthday: _birthday!,
        gender: _gender!,
        profilePicUrl: picUrl,
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveProfile(profile);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child: _pickedImage == null
                        ? const Icon(Icons.add_a_photo, size: 32, color: Colors.black54)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your age';
                  if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your country' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _districtCtrl,
                decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your district' : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickBirthday,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Birthday', border: OutlineInputBorder()),
                  child: Text(
                    _birthday == null
                        ? 'Select date'
                        : '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
