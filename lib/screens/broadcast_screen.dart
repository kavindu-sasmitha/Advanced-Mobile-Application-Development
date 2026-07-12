import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/live_stream.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _agoraService = AgoraService();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _titleCtrl = TextEditingController(text: "Let's vibe!");
  final _commentCtrl = TextEditingController();

  String? _streamId;
  String? _channelName;
  bool _isLive = false;
  bool _starting = false;

  @override
  void dispose() {
    _endStream();
    _agoraService.dispose();
    super.dispose();
  }

  Future<void> _goLive() async {
    setState(() => _starting = true);
    try {
      final user = _authService.currentUser!;
      final profile = await _firestoreService.getProfile(user.uid);

      _channelName = 'vc_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      await _agoraService.initEngine(isBroadcaster: true);
      await _agoraService.joinChannel(_channelName!, isBroadcaster: true);

      final stream = LiveStreamModel(
        id: '',
        hostUid: user.uid,
        hostName: profile?.name ?? user.displayName ?? 'Host',
        hostPicUrl: profile?.profilePicUrl ?? user.photoURL ?? '',
        title: _titleCtrl.text.trim().isEmpty ? 'Live now' : _titleCtrl.text.trim(),
        channelName: _channelName!,
        isLive: true,
        viewerCount: 0,
        likeCount: 0,
        createdAt: DateTime.now(),
      );

      _streamId = await _firestoreService.createStream(stream);
      setState(() {
        _isLive = true;
        _starting = false;
      });
    } catch (e) {
      setState(() => _starting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to go live: $e')));
      }
    }
  }

  Future<void> _endStream() async {
    if (_streamId != null && _isLive) {
      await _firestoreService.endStream(_streamId!);
      await _agoraService.leaveChannel();
      _isLive = false;
    }
  }

  Future<void> _sendComment() async {
    if (_commentCtrl.text.trim().isEmpty || _streamId == null) return;
    final user = _authService.currentUser!;
    final profile = await _firestoreService.getProfile(user.uid);
    await _firestoreService.addComment(
      _streamId!,
      user.uid,
      profile?.name ?? 'User',
      _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Go Live')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Stream title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _starting ? null : _goLive,
                icon: _starting
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.videocam),
                label: const Text('Start Streaming'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Local camera preview
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _agoraService.engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: () async {
                      await _endStream();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Comments
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 180,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _firestoreService.commentsStream(_streamId!),
                      builder: (context, snapshot) {
                        final comments = snapshot.data ?? [];
                        return ListView.builder(
                          reverse: true,
                          itemCount: comments.length,
                          itemBuilder: (context, i) {
                            final c = comments[comments.length - 1 - i];
                            return Text(
                              '${c['name']}: ${c['text']}',
                              style: const TextStyle(color: Colors.white),
                            );
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
