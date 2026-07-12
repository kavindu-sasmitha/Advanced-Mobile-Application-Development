import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/live_stream.dart';
import '../models/chat_request.dart';

class ViewStreamScreen extends StatefulWidget {
  final LiveStreamModel stream;
  const ViewStreamScreen({super.key, required this.stream});

  @override
  State<ViewStreamScreen> createState() => _ViewStreamScreenState();
}

class _ViewStreamScreenState extends State<ViewStreamScreen> {
  final _agoraService = AgoraService();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _commentCtrl = TextEditingController();

  int? _remoteUid;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _join();
  }

  Future<void> _join() async {
    final engine = await _agoraService.initEngine(isBroadcaster: false);

    engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) {
        setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        setState(() => _remoteUid = null);
      },
    ));

    await _agoraService.joinChannel(widget.stream.channelName, isBroadcaster: false);
    await _firestoreService.incrementViewer(widget.stream.id, 1);
    setState(() => _joined = true);
  }

  @override
  void dispose() {
    _firestoreService.incrementViewer(widget.stream.id, -1);
    _agoraService.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    final user = _authService.currentUser!;
    final profile = await _firestoreService.getProfile(user.uid);
    await _firestoreService.addComment(
      widget.stream.id,
      user.uid,
      profile?.name ?? 'User',
      _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();
  }

  Future<void> _requestChat() async {
    final user = _authService.currentUser!;
    if (user.uid == widget.stream.hostUid) return;
    final profile = await _firestoreService.getProfile(user.uid);

    await _firestoreService.sendChatRequest(ChatRequestModel(
      id: '',
      fromUid: user.uid,
      fromName: profile?.name ?? 'User',
      fromPicUrl: profile?.profilePicUrl ?? '',
      toUid: widget.stream.hostUid,
      status: 'pending',
      createdAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat request sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_joined && _remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _agoraService.engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.stream.channelName),
                ),
              )
            else
              const Center(
                child: Text('Connecting...', style: TextStyle(color: Colors.white70)),
              ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.stream.hostPicUrl.isNotEmpty
                        ? NetworkImage(widget.stream.hostPicUrl)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.stream.hostName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 100,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                    onPressed: () => _firestoreService.likeStream(widget.stream.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 28),
                    tooltip: 'Request private chat',
                    onPressed: _requestChat,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 70,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 160,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestoreService.commentsStream(widget.stream.id),
                      builder: (context, snapshot) {
                        final comments = snapshot.data ?? [];
                        return ListView.builder(
                          reverse: true,
                          itemCount: comments.length,
                          itemBuilder: (context, i) {
                            final c = comments[comments.length - 1 - i];
                            return Text('${c['name']}: ${c['text']}', style: const TextStyle(color: Colors.white));
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Say something...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
