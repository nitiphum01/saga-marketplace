import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/widgets/saga_app_bar.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/chat/providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().getCurrentUserId();

    return Scaffold(
      appBar: SagaAppBar(
        title: Text(
          'Chats',
          style: GoogleFonts.kanit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.kanit(fontSize: 14),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: context.read<ChatProvider>().streamConversationsForUser(
                currentUserId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.mfuRed),
                  );
                }

                if (snapshot.hasError) {
                  print('🔥 FIRESTORE ERROR: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'DEBUG: Firestore Error',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '⚠️ Check Debug Console for full error',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? const [];
                print('✅ Fetched ${docs.length} conversations from Firestore');
                final query = _searchQuery.trim().toLowerCase();

                final visibleDocs = docs.where((doc) {
                  final data = doc.data();
                  final deletedBy =
                      (data['deletedBy'] as List?)
                          ?.whereType<String>()
                          .toList() ??
                      <String>[];
                  return !deletedBy.contains(currentUserId);
                }).toList();

                final filteredDocs = query.isEmpty
                    ? visibleDocs
                    : visibleDocs.where((doc) {
                        final data = doc.data();
                        final productInfo =
                            data['productInfo'] as Map<String, dynamic>? ??
                            const <String, dynamic>{};
                        final title = (productInfo['title'] as String? ?? '')
                            .toLowerCase();
                        final lastMessage =
                            (data['lastMessage'] as String? ?? '')
                                .toLowerCase();
                        final sellerName = (data['sellerName'] as String? ?? '')
                            .toLowerCase();
                        return title.contains(query) ||
                            lastMessage.contains(query) ||
                            sellerName.contains(query);
                      }).toList();

                filteredDocs.sort((a, b) {
                  final aData = a.data();
                  final bData = b.data();

                  final aPinnedBy =
                      (aData['pinnedBy'] as List?)
                          ?.whereType<String>()
                          .toList() ??
                      <String>[];
                  final bPinnedBy =
                      (bData['pinnedBy'] as List?)
                          ?.whereType<String>()
                          .toList() ??
                      <String>[];

                  final aPinned = aPinnedBy.contains(currentUserId);
                  final bPinned = bPinnedBy.contains(currentUserId);

                  if (aPinned != bPinned) {
                    return aPinned ? -1 : 1;
                  }

                  final aTs = aData['lastTimestamp'] as Timestamp?;
                  final bTs = bData['lastTimestamp'] as Timestamp?;
                  final aMs = aTs?.millisecondsSinceEpoch ?? 0;
                  final bMs = bTs?.millisecondsSinceEpoch ?? 0;

                  return bMs.compareTo(aMs);
                });

                if (filteredDocs.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 72,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No conversations yet',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Start chatting from a product detail page.',
                          style: GoogleFonts.kanit(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  itemCount: filteredDocs.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 76,
                  ),
                  itemBuilder: (context, index) {
                    try {
                      final doc = filteredDocs[index];
                      final data = doc.data();

                      final participants =
                          (data['participants'] as List?)
                              ?.whereType<String>()
                              .toList() ??
                          <String>[];
                      final fallbackOtherUserId = participants.firstWhere(
                        (id) => id != currentUserId,
                        orElse: () => data['sellerId'] as String? ?? 'Seller',
                      );

                      final sellerName =
                          data['sellerName'] as String? ??
                          'Seller ${_shortId(fallbackOtherUserId)}';

                      final productInfo =
                          data['productInfo'] as Map<String, dynamic>? ??
                          const <String, dynamic>{};
                      final productTitle =
                          productInfo['title'] as String? ??
                          'Product conversation';
                      final lastMessage =
                          data['lastMessage'] as String? ?? 'No messages yet';
                      final pinnedBy =
                          (data['pinnedBy'] as List?)
                              ?.whereType<String>()
                              .toList() ??
                          <String>[];
                      final isPinned = pinnedBy.contains(currentUserId);
                      // ⚠️ FIRESTORE COMPOSITE INDEX REMINDER:
                      // If you see a gRPC error about missing composite index,
                      // click the Firebase Console link in the Debug Console.
                      // It will auto-create the index for:
                      //   - participants (Array)
                      //   - lastTimestamp (Descending)
                      final timestamp = data['lastTimestamp'] as Timestamp?;

                      return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>
                      >(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(fallbackOtherUserId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey.shade300,
                              ),
                              title: Container(
                                height: 14,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  productTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }

                          final userData = userSnapshot.data?.data();

                          final displayName =
                              (userData?['displayName'] as String?)
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? (userData?['displayName'] as String).trim()
                              : sellerName;

                          // Future-proof: use photoUrl when profile image uploads are added.
                          final photoUrl =
                              (userData?['photoUrl'] as String?)?.trim() ?? '';

                          final avatarLetter = displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.mfuBlue.withValues(
                                alpha: 0.12,
                              ),
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isNotEmpty
                                  ? null
                                  : Text(
                                      avatarLetter,
                                      style: GoogleFonts.kanit(
                                        color: AppColors.mfuBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.kanit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isPinned)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.push_pin,
                                      size: 16,
                                      color: AppColors.mfuBlue,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kanit(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lastMessage.isEmpty
                                      ? 'New conversation started'
                                      : lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              _formatTime(timestamp?.toDate()),
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            onTap: () {
                              context.push(
                                '/chat-room',
                                extra: {
                                  'roomId': doc.id,
                                  'product': null,
                                  'sellerId':
                                      data['sellerId'] as String? ??
                                      fallbackOtherUserId,
                                },
                              );
                            },
                            onLongPress: () async {
                              await _showChatActionsSheet(
                                context: context,
                                roomId: doc.id,
                                isPinned: isPinned,
                                currentUserId: currentUserId,
                              );
                            },
                          );
                        },
                      );
                    } catch (e) {
                      print('❌ Mapping Error at index $index: $e');
                      return ListTile(
                        title: const Text('Corrupted Chat Entry'),
                        subtitle: Text(
                          'Error: ${e.toString()}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return '${id.substring(0, 8)}...';
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '--:--';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    }
    return DateFormat('dd/MM/yy').format(time);
  }

  Future<void> _showChatActionsSheet({
    required BuildContext context,
    required String roomId,
    required bool isPinned,
    required String currentUserId,
  }) async {
    final provider = context.read<ChatProvider>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                    color: AppColors.mfuBlue,
                  ),
                  title: Text(
                    isPinned ? 'Unpin Chat' : 'Pin Chat',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    try {
                      await provider.togglePinStatus(
                        roomId: roomId,
                        currentUserId: currentUserId,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to update pin: $e')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete Chat',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: Text(
                            'Delete chat?',
                            style: GoogleFonts.kanit(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            'This chat will be removed from your list. It will remain visible for the other user unless they also delete it.',
                            style: GoogleFonts.kanit(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed != true) {
                      return;
                    }

                    try {
                      await provider.deleteConversation(
                        roomId: roomId,
                        currentUserId: currentUserId,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to delete chat: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
