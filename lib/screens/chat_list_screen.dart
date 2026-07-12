import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/chat_request.dart';
import '../models/user_profile.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Requests'),
            Tab(text: 'Chats'),
          ]),
        ),
        body: TabBarView(
          children: [
            _RequestsTab(uid: uid),
            _ChatsTab(uid: uid),
          ],
        ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final String uid;
  const _RequestsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<ChatRequestModel>>(
      stream: firestoreService.incomingRequests(uid),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No pending chat requests'));
        }
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, i) {
            final r = requests[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: r.fromPicUrl.isNotEmpty ? NetworkImage(r.fromPicUrl) : null,
                child: r.fromPicUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(r.fromName),
              subtitle: const Text('wants to chat privately'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => firestoreService.respondToRequest(r.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => firestoreService.respondToRequest(r.id, false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatsTab extends StatelessWidget {
  final String uid;
  const _ChatsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<ChatRequestModel>>(
      stream: firestoreService.acceptedChats(uid),
      builder: (context, snapshot) {
        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return const Center(child: Text('No active chats yet'));
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, i) {
            final r = chats[i];
            final otherUid = r.fromUid == uid ? r.toUid : r.fromUid;

            return FutureBuilder<UserProfile?>(
              future: firestoreService.getProfile(otherUid),
              builder: (context, snap) {
                final profile = snap.data;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile != null && profile.profilePicUrl.isNotEmpty
                        ? NetworkImage(profile.profilePicUrl)
                        : null,
                    child: profile == null || profile.profilePicUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  // Requirement: private chat shows the other user's profile as the chat name
                  title: Text(profile?.name ?? 'Loading...'),
                  subtitle: Text(profile != null ? '${profile.country} • ${profile.district}' : ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          otherUid: otherUid,
                          otherName: profile?.name ?? 'Chat',
                          otherPicUrl: profile?.profilePicUrl ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
