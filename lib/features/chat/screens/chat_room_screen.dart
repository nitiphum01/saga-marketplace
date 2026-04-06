import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/widgets/platform_file_preview.dart';
import 'package:flutter_application_1/core/widgets/saga_app_bar.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';

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
  late final TextEditingController _messageController;
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

  Future<void> _sendMessage() async {
    if (_currentRoomId == null) {
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final currentUserId = context.read<AuthProvider>().getCurrentUserId();
    try {
      await context.read<ChatProvider>().sendMessage(
        roomId: _currentRoomId!,
        text: text,
        senderId: currentUserId,
        product: widget.product,
        sellerId: widget.sellerId,
      );
      if (!mounted) {
        return;
      }
      _messageController.clear();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e', style: GoogleFonts.kanit())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoomId == null || _currentRoomId!.trim().isEmpty) {
      return Scaffold(
        appBar: SagaAppBar(
          title: Text(
            'Chat',
            style: GoogleFonts.kanit(fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Text(
            'Conversation not found.',
            style: GoogleFonts.kanit(fontSize: 16),
          ),
        ),
      );
    }

    final currentUserId = context.read<AuthProvider>().getCurrentUserId();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: SagaAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: context.read<ChatProvider>().streamConversation(
            _currentRoomId!,
          ),
          builder: (context, snapshot) {
            final conversationData =
                snapshot.data?.data() ?? const <String, dynamic>{};
            final participants =
                (conversationData['participants'] as List?)
                    ?.whereType<String>()
                    .toList() ??
                <String>[];

            final otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => widget.sellerId,
            );

            final displayName = 'Seller ${_shortId(otherUserId)}';
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.mfuBlue.withValues(alpha: 0.12),
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mfuBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
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
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: context.read<ChatProvider>().streamConversation(
              _currentRoomId!,
            ),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final productInfo = data == null
                  ? null
                  : data['productInfo'] as Map<String, dynamic>?;
              return _buildProductContextBar(productInfo);
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<ChatProvider>().streamMessages(
                _currentRoomId!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.mfuRed),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load messages.',
                      style: GoogleFonts.kanit(),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final senderId = data['senderId'] as String? ?? '';
                    final text = data['text'] as String? ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final isSent = senderId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MessageBubble(
                        message: text,
                        isSent: isSent,
                        timestamp: _formatTime(timestamp?.toDate()),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildProductContextBar(Map<String, dynamic>? productInfo) {
    final title = productInfo == null
        ? widget.product?.title ?? 'Product conversation'
        : productInfo['title'] as String? ?? 'Product conversation';

    final image = productInfo == null
        ? widget.product?.imageUrl ?? ''
        : productInfo['image'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PlatformFilePreview(path: image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.kanit(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
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
                    borderSide: const BorderSide(color: AppColors.mfuRed),
                  ),
                ),
                style: GoogleFonts.kanit(fontSize: 14),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.mfuRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '--:--';
    }
    return DateFormat('HH:mm').format(time);
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return '${id.substring(0, 8)}...';
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isSent;
  final String timestamp;

  const _MessageBubble({
    required this.message,
    required this.isSent,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isSent ? 18 : 6),
      bottomRight: Radius.circular(isSent ? 6 : 18),
    );

    return Row(
      mainAxisAlignment: isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSent ? AppColors.mfuRed : Colors.grey.shade200,
              borderRadius: bubbleRadius,
            ),
            child: Column(
              crossAxisAlignment: isSent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    color: isSent ? Colors.white : Colors.black87,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: GoogleFonts.kanit(
                    fontSize: 11,
                    color: isSent
                        ? Colors.white.withValues(alpha: 0.75)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
