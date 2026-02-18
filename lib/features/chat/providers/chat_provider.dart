import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/chat/models/chat_model.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';

/// Provider for managing chat state
class ChatProvider extends ChangeNotifier {
  List<ChatRoom> _chatRooms = [];

  ChatProvider() {
    _initializeMockData();
  }

  /// Initialize mock chat rooms
  void _initializeMockData() {
    final now = DateTime.now();

    _chatRooms = [
      ChatRoom(
        id: 'room_001',
        productId: 'product_001',
        productTitle: 'Calculus Textbook',
        productImage: 'https://via.placeholder.com/300?text=Calculus',
        otherUserId: 'seller_001',
        otherUserName: 'Somchai',
        lastMessage: 'Yes, can meet at M-Square?',
        lastMessageTime: now.subtract(const Duration(minutes: 15)),
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'msg_001',
            senderId: 'user_123',
            text: 'Is this still available?',
            timestamp: now.subtract(const Duration(minutes: 30)),
            isRead: true,
          ),
          ChatMessage(
            id: 'msg_002',
            senderId: 'seller_001',
            text: 'Yes, can meet at M-Square?',
            timestamp: now.subtract(const Duration(minutes: 15)),
            isRead: false,
          ),
        ],
      ),
      ChatRoom(
        id: 'room_002',
        productId: 'product_005',
        productTitle: 'Scientific Calculator',
        productImage: 'https://via.placeholder.com/300?text=Calculator',
        otherUserId: 'seller_002',
        otherUserName: 'Malee',
        lastMessage: 'Ok, see you tomorrow!',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'msg_003',
            senderId: 'user_123',
            text: 'Can I see it tomorrow?',
            timestamp: now.subtract(const Duration(hours: 3)),
            isRead: true,
          ),
          ChatMessage(
            id: 'msg_004',
            senderId: 'seller_002',
            text: 'Ok, see you tomorrow!',
            timestamp: now.subtract(const Duration(hours: 2)),
            isRead: true,
          ),
        ],
      ),
      ChatRoom(
        id: 'room_003',
        productId: 'product_008',
        productTitle: 'Lab Coat (White)',
        productImage: 'https://via.placeholder.com/300?text=Lab+Coat',
        otherUserId: 'seller_003',
        otherUserName: 'Nida',
        lastMessage: 'Size M available',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 2,
        messages: [
          ChatMessage(
            id: 'msg_005',
            senderId: 'user_123',
            text: 'What size is this?',
            timestamp: now.subtract(const Duration(days: 1, hours: 2)),
            isRead: true,
          ),
          ChatMessage(
            id: 'msg_006',
            senderId: 'seller_003',
            text: 'Size M available',
            timestamp: now.subtract(const Duration(days: 1)),
            isRead: false,
          ),
        ],
      ),
    ];
  }

  /// Returns list of chat rooms sorted by time (newest first)
  List<ChatRoom> get chatRooms {
    final sorted = List<ChatRoom>.from(_chatRooms);
    sorted.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return sorted;
  }

  /// Get a specific chat room by ID
  ChatRoom? getChatRoomById(String roomId) {
    try {
      return _chatRooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  /// Initiate or get existing chat for a product
  String initiateChat(Product product, String currentUserId) {
    // Check if chat room already exists for this product and user
    try {
      final existingRoom = _chatRooms.firstWhere(
        (room) => room.productId == product.id,
      );
      return existingRoom.id;
    } catch (e) {
      // No existing room, create new one
      final now = DateTime.now();
      final newRoomId = 'room_${now.millisecondsSinceEpoch}';

      final newRoom = ChatRoom(
        id: newRoomId,
        productId: product.id,
        productTitle: product.title,
        productImage: product.imageUrl,
        otherUserId: product.sellerId,
        otherUserName: 'Seller ${product.sellerId.substring(0, 7)}',
        lastMessage: 'Chat started',
        lastMessageTime: now,
        unreadCount: 0,
        messages: [],
      );

      _chatRooms.add(newRoom);
      notifyListeners();
      return newRoomId;
    }
  }

  /// Send a message in a chat room
  void sendMessage(String roomId, String text, String senderId) {
    final roomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) return;

    final now = DateTime.now();
    final messageId = 'msg_${now.millisecondsSinceEpoch}';

    final newMessage = ChatMessage(
      id: messageId,
      senderId: senderId,
      text: text,
      timestamp: now,
      isRead: false,
    );

    final room = _chatRooms[roomIndex];
    final updatedMessages = [...room.messages, newMessage];

    // Update the chat room
    _chatRooms[roomIndex] = room.copyWith(
      messages: updatedMessages,
      lastMessage: text,
      lastMessageTime: now,
      // Reset unread count if sender is current user
      unreadCount: senderId == 'user_123' ? 0 : room.unreadCount + 1,
    );

    notifyListeners();
  }

  /// Mark messages as read in a chat room
  void markAsRead(String roomId) {
    final roomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) return;

    final room = _chatRooms[roomIndex];
    _chatRooms[roomIndex] = room.copyWith(unreadCount: 0);
    notifyListeners();
  }

  /// Get total unread count across all rooms
  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }
}
