import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/live_stream.dart';

class StreamCard extends StatelessWidget {
  final LiveStreamModel stream;
  final VoidCallback onTap;

  const StreamCard({super.key, required this.stream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black87,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (stream.hostPicUrl.isNotEmpty)
              Opacity(
                opacity: 0.55,
                child: CachedNetworkImage(
                  imageUrl: stream.hostPicUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: Colors.grey.shade800),
                ),
              )
            else
              Container(color: Colors.grey.shade800),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                  const SizedBox(width: 3),
                  Text('${stream.viewerCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stream.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(stream.hostName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
