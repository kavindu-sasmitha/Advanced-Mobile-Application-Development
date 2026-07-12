import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStreamModel {
  final String id;
  final String hostUid;
  final String hostName;
  final String hostPicUrl;
  final String title;
  final String channelName;
  final bool isLive;
  final int viewerCount;
  final int likeCount;
  final DateTime createdAt;

  LiveStreamModel({
    required this.id,
    required this.hostUid,
    required this.hostName,
    required this.hostPicUrl,
    required this.title,
    required this.channelName,
    required this.isLive,
    required this.viewerCount,
    required this.likeCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'hostUid': hostUid,
      'hostName': hostName,
      'hostPicUrl': hostPicUrl,
      'title': title,
      'channelName': channelName,
      'isLive': isLive,
      'viewerCount': viewerCount,
      'likeCount': likeCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LiveStreamModel.fromMap(String id, Map<String, dynamic> map) {
    return LiveStreamModel(
      id: id,
      hostUid: map['hostUid'] ?? '',
      hostName: map['hostName'] ?? '',
      hostPicUrl: map['hostPicUrl'] ?? '',
      title: map['title'] ?? '',
      channelName: map['channelName'] ?? '',
      isLive: map['isLive'] ?? false,
      viewerCount: map['viewerCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
