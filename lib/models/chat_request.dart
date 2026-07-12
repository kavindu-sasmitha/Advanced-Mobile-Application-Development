import 'package:cloud_firestore/cloud_firestore.dart';

// status: pending | accepted | rejected
class ChatRequestModel {
  final String id;
  final String fromUid;
  final String fromName;
  final String fromPicUrl;
  final String toUid;
  final String status;
  final DateTime createdAt;

  ChatRequestModel({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.fromPicUrl,
    required this.toUid,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'fromName': fromName,
      'fromPicUrl': fromPicUrl,
      'toUid': toUid,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatRequestModel(
      id: id,
      fromUid: map['fromUid'] ?? '',
      fromName: map['fromName'] ?? '',
      fromPicUrl: map['fromPicUrl'] ?? '',
      toUid: map['toUid'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Deterministic chat id so both users land in the same chat doc
  static String chatIdFor(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }
}
