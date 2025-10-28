import 'package:flutter/material.dart';  
import '../widgets/message_limit_banner.dart';
import '../../../../core/services/subscription_service.dart';


class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  
  bool _isPremium = false;
  int _remainingMessages = 50;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    // Comentado temporalmente hasta que se implemente el evento
    // _loadMessageLimit();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await SubscriptionService().isPremiumUser();
    setState(() => _isPremium = isPremium);
  }

  // Comentado temporalmente - LoadMessageLimit no está definido en chat_event.dart
  // Future<void> _loadMessageLimit() async {
  //   context.read<ChatBloc>().add(LoadMessageLimit(widget.conversationId));
  // }

  void _onMessagesUnlocked() {
    setState(() => _remainingMessages += 10);
    // _loadMessageLimit(); // También comentado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.otherUserName[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!_isPremium)
            MessageLimitBanner(
              remainingMessages: _remainingMessages,
              onMessagesUnlocked: _onMessagesUnlocked,
            ),
        ],
      ),
    );
  }
}