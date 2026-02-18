import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';
import 'package:flutter_application_1/features/chat/models/chat_model.dart';
import 'package:intl/intl.dart';

/// Screen displaying list of active chat conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          'Chat',
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final chatRooms = chatProvider.chatRooms;
          final searchQuery = _searchQuery.trim().toLowerCase();
          final filteredRooms = searchQuery.isEmpty
              ? chatRooms
              : chatRooms
                    .where(
                      (room) => room.otherUserName.toLowerCase().contains(
                        searchQuery,
                      ),
                    )
                    .toList();

          if (filteredRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No conversations yet',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with sellers!',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.kanit(fontSize: 14),
                ),
              ),

              // Chat List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredRooms.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final chatRoom = filteredRooms[index];
                    return _ChatListTile(chatRoom: chatRoom);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom chatRoom;

  const _ChatListTile({required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
              child: Text(
                chatRoom.otherUserName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.kanit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ),
            if (chatRoom.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFB71C1C),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      chatRoom.unreadCount > 9
                          ? '9+'
                          : chatRoom.unreadCount.toString(),
                      style: GoogleFonts.kanit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chatRoom.otherUserName,
          style: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${chatRoom.productTitle}: ',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                    TextSpan(
                      text: chatRoom.lastMessage,
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: chatRoom.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: chatRoom.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chatRoom.lastMessageTime),
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: chatRoom.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: chatRoom.unreadCount > 0
                    ? const Color(0xFFB71C1C)
                    : Colors.grey.shade500,
              ),
            ),
            if (chatRoom.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          // Mark as read when opening chat
          context.read<ChatProvider>().markAsRead(chatRoom.id);

          // Navigate to chat room
          context.push(
            '/chat-room',
            extra: {
              'roomId': chatRoom.id,
              'product': null,
              'sellerId': chatRoom.otherUserId,
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }
}
