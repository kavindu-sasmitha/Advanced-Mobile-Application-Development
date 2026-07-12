import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/chat_request.dart';

class ChatScreen extends StatefulWidget {
  final String otherUid;
  final String otherName;
  final String otherPicUrl;

  const ChatScreen({
    super.key,
    required this.otherUid,
    required this.otherName,
    required this.otherPicUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _msgCtrl = TextEditingController();
  late final String _chatId;
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = _authService.currentUser!.uid;
    _chatId = ChatRequestModel.chatIdFor(_myUid, widget.otherUid);
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    await _firestoreService.sendMessage(_chatId, _myUid, _msgCtrl.text.trim());
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherPicUrl.isNotEmpty ? NetworkImage(widget.otherPicUrl) : null,
              child: widget.otherPicUrl.isEmpty ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 10),
            // Chat is labelled with the other user's profile name, as required
            Text(widget.otherName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.messagesStream(_chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[messages.length - 1 - i];
                    final isMe = m['senderUid'] == _myUid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.deepPurple : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          m['text'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
