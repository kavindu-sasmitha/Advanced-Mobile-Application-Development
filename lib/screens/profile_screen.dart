import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final uid = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: firestoreService.profileStream(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: profile.profilePicUrl.isNotEmpty
                      ? NetworkImage(profile.profilePicUrl)
                      : null,
                  child: profile.profilePicUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              _infoTile(Icons.cake, 'Age', '${profile.age}'),
              _infoTile(Icons.public, 'Country', profile.country),
              _infoTile(Icons.location_on, 'District', profile.district),
              _infoTile(Icons.calendar_today, 'Birthday',
                  '${profile.birthday.day}/${profile.birthday.month}/${profile.birthday.year}'),
              _infoTile(Icons.wc, 'Gender', profile.gender),
              _infoTile(Icons.email, 'Email', profile.email),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
