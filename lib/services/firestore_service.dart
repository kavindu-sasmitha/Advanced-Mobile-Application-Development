import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/live_stream.dart';
import '../models/chat_request.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---------------- PROFILE ----------------
  Future<bool> profileExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  Stream<UserProfile?> profileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!);
    });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ---------------- LIVE STREAMS ----------------
  Future<String> createStream(LiveStreamModel stream) async {
    final doc = await _db.collection('streams').add(stream.toMap());
    return doc.id;
  }

  Future<void> endStream(String streamId) async {
    await _db.collection('streams').doc(streamId).update({'isLive': false});
  }

  Stream<List<LiveStreamModel>> liveStreamsList() {
    return _db
        .collection('streams')
        .where('isLive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LiveStreamModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> incrementViewer(String streamId, int delta) async {
    await _db.collection('streams').doc(streamId).update({
      'viewerCount': FieldValue.increment(delta),
    });
  }

  Future<void> likeStream(String streamId) async {
    await _db.collection('streams').doc(streamId).update({
      'likeCount': FieldValue.increment(1),
    });
  }

  // comments subcollection
  Future<void> addComment(String streamId, String uid, String name, String text) async {
    await _db
        .collection('streams')
        .doc(streamId)
        .collection('comments')
        .add({
      'uid': uid,
      'name': name,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> commentsStream(String streamId) {
    return _db
        .collection('streams')
        .doc(streamId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ---------------- CHAT REQUESTS ----------------
  Future<void> sendChatRequest(ChatRequestModel req) async {
    // avoid duplicate pending requests
    final existing = await _db
        .collection('chatRequests')
        .where('fromUid', isEqualTo: req.fromUid)
        .where('toUid', isEqualTo: req.toUid)
        .where('status', isEqualTo: 'pending')
        .get();
    if (existing.docs.isNotEmpty) return;

    await _db.collection('chatRequests').add(req.toMap());
  }

  Stream<List<ChatRequestModel>> incomingRequests(String uid) {
    return _db
        .collection('chatRequests')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatRequestModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    await _db.collection('chatRequests').doc(requestId).update({
      'status': accept ? 'accepted' : 'rejected',
    });
  }

  // list of uids this user has an accepted chat with
  Stream<List<ChatRequestModel>> acceptedChats(String uid) {
    return _db
        .collection('chatRequests')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatRequestModel.fromMap(d.id, d.data()))
            .where((r) => r.fromUid == uid || r.toUid == uid)
            .toList());
  }

  // ---------------- CHAT MESSAGES ----------------
  Future<void> sendMessage(String chatId, String senderUid, String text) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.set({
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderUid': senderUid,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> messagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
