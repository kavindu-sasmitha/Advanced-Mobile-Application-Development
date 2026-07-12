import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/live_stream.dart';
import '../widgets/stream_card.dart';
import 'broadcast_screen.dart';
import 'view_stream_screen.dart';

class LiveStreamListScreen extends StatelessWidget {
  const LiveStreamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Go Live',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BroadcastScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<LiveStreamModel>>(
        stream: firestoreService.liveStreamsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final streams = snapshot.data ?? [];
          if (streams.isEmpty) {
            return const Center(child: Text('No one is live right now.\nBe the first!', textAlign: TextAlign.center));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: streams.length,
            itemBuilder: (context, i) {
              final s = streams[i];
              return StreamCard(
                stream: s,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ViewStreamScreen(stream: s)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BroadcastScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Go Live'),
      ),
    );
  }
}
