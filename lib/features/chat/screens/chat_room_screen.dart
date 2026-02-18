import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';
import 'package:flutter_application_1/features/chat/models/chat_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final String? roomId;
  final Product? product;
  final String sellerId;

  const ChatRoomScreen({
    this.roomId,
    this.product,
    required this.sellerId,
    super.key,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late TextEditingController _messageController;
  String? _currentRoomId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _currentRoomId = widget.roomId;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty || _currentRoomId == null) return;

    context.read<ChatProvider>().sendMessage(
      _currentRoomId!,
      _messageController.text,
      'user_123', // Current user ID
    );

    _messageController.clear();

    // Scroll to bottom after sending
    // Future implementation: Add ScrollController
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            if (_currentRoomId == null) return const SizedBox();

            final room = chatProvider.getChatRoomById(_currentRoomId!);
            if (room == null) return const SizedBox();

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                  child: Text(
                    room.otherUserName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    room.otherUserName,
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (_currentRoomId == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final room = chatProvider.getChatRoomById(_currentRoomId!);
          if (room == null) {
            return Center(
              child: Text('Chat room not found', style: GoogleFonts.kanit()),
            );
          }

          return Column(
            children: [
              // Product Context Bar
              _buildProductContextBar(room),
              // Messages List
              Expanded(child: _buildMessageList(room.messages)),
              // Message Input Area
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the product context bar showing the item being discussed
  Widget _buildProductContextBar(ChatRoom room) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                room.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.productTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chatting about this item',
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the messages list
  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.kanit(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isSent = message.senderId == 'user_123';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MessageBubble(
            message: message,
            isSent: isSent,
            timestamp: _formatTime(message.timestamp),
          ),
        );
      },
    );
  }

  /// Builds the message input area
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.kanit(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFB71C1C)),
                ),
              ),
              style: GoogleFonts.kanit(fontSize: 14),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFB71C1C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSent;
  final String timestamp;

  const _MessageBubble({
    required this.message,
    required this.isSent,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSent ? const Color(0xFFB71C1C) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  color: isSent ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timestamp,
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  color: isSent
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
