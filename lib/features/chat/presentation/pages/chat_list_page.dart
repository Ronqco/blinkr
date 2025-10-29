import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatLoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search conversations
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(ChatLoadConversations());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text('No tienes conversaciones'),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre gente nueva para empezar a chatear',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Switch to discovery tab (index 1)
                        // Assuming you have access to the parent TabController
                        // For now, just navigate
                        context.push('/discovery');
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Descubrir personas'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(ChatLoadConversations());
              },
              child: ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: conversation.otherAvatarUrl != null
                              ? CachedNetworkImageProvider(
                                  conversation.otherAvatarUrl!)
                              : null,
                          child: conversation.otherAvatarUrl == null
                              ? Text(
                                  conversation.otherDisplayName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 20),
                                )
                              : null,
                        ),
                        // Online indicator (if available)
                        // Positioned(
                        //   right: 0,
                        //   bottom: 0,
                        //   child: Container(
                        //     width: 14,
                        //     height: 14,
                        //     decoration: BoxDecoration(
                        //       color: Colors.green,
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: Theme.of(context).scaffoldBackgroundColor,
                        //         width: 2,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    title: Text(
                      conversation.otherDisplayName,
                      style: TextStyle(
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Toca para abrir el chat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: conversation.unreadCount > 0
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(
                            conversation.lastMessageAt,
                            locale: 'es',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      context.push('/chat/${conversation.id}');
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to discovery to start new chat
          context.push('/discovery');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}