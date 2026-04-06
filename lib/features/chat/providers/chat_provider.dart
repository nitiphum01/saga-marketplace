import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';

/// Firestore-backed provider for conversations and messages.
class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  ChatProvider({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('conversations');

  String _buildConversationId({
    required String productId,
    required String userA,
    required String userB,
  }) {
    final participants = [userA.trim(), userB.trim()]..sort();
    final safeProductId = productId.replaceAll('/', '_');
    return '${safeProductId}_${participants[0]}_${participants[1]}';
  }

  /// Ensures a conversation document exists and returns its deterministic id.
  /// Creates new conversation if it doesn't exist, or returns existing if it does.
  Future<String> initiateChat(Product product, String currentUserId) async {
    final buyerId = currentUserId.trim();
    final sellerId = product.sellerId.trim();

    if (buyerId.isEmpty || buyerId == 'user_guest') {
      throw Exception('Please sign in before starting a chat.');
    }

    if (sellerId.isEmpty) {
      throw Exception('Invalid seller for this product.');
    }

    final conversationId = _buildConversationId(
      productId: product.id,
      userA: buyerId,
      userB: sellerId,
    );

    final participants = [buyerId, sellerId]..sort();

    /// Create seller name display (can be customized later with user profile data)
    final sellerDisplayName =
        'Seller ${sellerId.substring(0, sellerId.length >= 6 ? 6 : sellerId.length)}';

    await _conversationsRef.doc(conversationId).set({
      'conversationId': conversationId,
      'participants': participants,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'sellerName': sellerDisplayName,
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'productInfo': {
        'id': product.id,
        'title': product.title,
        'image': product.imageUrl,
      },
    }, SetOptions(merge: true));

    return conversationId;
  }

  /// Sends a message and updates the parent conversation metadata atomically.
  Future<void> sendMessage({
    required String roomId,
    required String text,
    required String senderId,
    Product? product,
    String? sellerId,
  }) async {
    final messageText = text.trim();
    final safeSenderId = senderId.trim();

    if (roomId.trim().isEmpty) {
      throw Exception('Invalid room id.');
    }
    if (messageText.isEmpty) {
      return;
    }
    if (safeSenderId.isEmpty || safeSenderId == 'user_guest') {
      throw Exception('Please sign in before sending a message.');
    }

    final conversationRef = _conversationsRef.doc(roomId);
    final conversationSnap = await conversationRef.get();
    final existing = conversationSnap.data() ?? <String, dynamic>{};

    final existingParticipants =
        (existing['participants'] as List?)?.whereType<String>().toList() ??
        <String>[];

    final resolvedSellerId =
        (existing['sellerId'] as String?)?.trim().isNotEmpty == true
        ? (existing['sellerId'] as String).trim()
        : (sellerId ?? product?.sellerId ?? '').trim();

    final participants = existingParticipants.isNotEmpty
        ? existingParticipants
        : <String>[
            safeSenderId,
            resolvedSellerId,
          ].where((id) => id.isNotEmpty).toList();

    if (participants.length < 2) {
      throw Exception('Unable to resolve participants for this conversation.');
    }

    participants.sort();

    final existingProductInfo =
        existing['productInfo'] as Map<String, dynamic>?;
    final productInfo =
        existingProductInfo ??
        (product == null
            ? null
            : {
                'id': product.id,
                'title': product.title,
                'image': product.imageUrl,
              });

    final messageRef = conversationRef.collection('messages').doc();
    final batch = _firestore.batch();

    batch.set(messageRef, {
      'id': messageRef.id,
      'senderId': safeSenderId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final sellerName =
        existing['sellerName'] as String? ??
        'Seller ${resolvedSellerId.substring(0, resolvedSellerId.length >= 6 ? 6 : resolvedSellerId.length)}';

    batch.set(conversationRef, {
      'conversationId': roomId,
      'participants': participants,
      'sellerId': resolvedSellerId,
      'sellerName': sellerName,
      'lastMessage': messageText,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!conversationSnap.exists) 'createdAt': FieldValue.serverTimestamp(),
      if (productInfo != null) 'productInfo': productInfo,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamConversationsForUser(
    String currentUserId,
  ) {
    return _conversationsRef
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamConversation(
    String roomId,
  ) {
    return _conversationsRef.doc(roomId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String roomId) {
    return _conversationsRef
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> togglePinStatus({
    required String roomId,
    required String currentUserId,
  }) async {
    final safeRoomId = roomId.trim();
    final safeUserId = currentUserId.trim();

    if (safeRoomId.isEmpty) {
      throw Exception('Invalid room id.');
    }
    if (safeUserId.isEmpty || safeUserId == 'user_guest') {
      throw Exception('Please sign in first.');
    }

    final ref = _conversationsRef.doc(safeRoomId);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) {
        throw Exception('Conversation not found.');
      }

      final data = snap.data() ?? <String, dynamic>{};
      final pinnedBy =
          (data['pinnedBy'] as List?)?.whereType<String>().toSet() ??
          <String>{};

      if (pinnedBy.contains(safeUserId)) {
        transaction.update(ref, {
          'pinnedBy': FieldValue.arrayRemove([safeUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(ref, {
          'pinnedBy': FieldValue.arrayUnion([safeUserId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> deleteConversation({
    required String roomId,
    required String currentUserId,
  }) async {
    final safeRoomId = roomId.trim();
    final safeUserId = currentUserId.trim();

    if (safeRoomId.isEmpty) {
      throw Exception('Invalid room id.');
    }
    if (safeUserId.isEmpty || safeUserId == 'user_guest') {
      throw Exception('Please sign in first.');
    }

    final ref = _conversationsRef.doc(safeRoomId);

    final shouldHardDelete = await _firestore.runTransaction<bool>((
      transaction,
    ) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) {
        return false;
      }

      final data = snap.data() ?? <String, dynamic>{};
      final participants =
          (data['participants'] as List?)?.whereType<String>().toList() ??
          <String>[];

      final deletedBy =
          (data['deletedBy'] as List?)?.whereType<String>().toSet() ??
          <String>{};
      deletedBy.add(safeUserId);

      final allParticipantsDeleted =
          participants.isNotEmpty && participants.every(deletedBy.contains);

      if (allParticipantsDeleted) {
        return true;
      }

      transaction.update(ref, {
        'deletedBy': FieldValue.arrayUnion([safeUserId]),
        'pinnedBy': FieldValue.arrayRemove([safeUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return false;
    });

    if (shouldHardDelete) {
      await _deleteConversationAndMessages(safeRoomId);
    }
  }

  Future<void> _deleteConversationAndMessages(String roomId) async {
    final conversationRef = _conversationsRef.doc(roomId);

    while (true) {
      final messagesSnap = await conversationRef
          .collection('messages')
          .limit(400)
          .get();

      if (messagesSnap.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();
      for (final doc in messagesSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await conversationRef.delete();
  }
}
