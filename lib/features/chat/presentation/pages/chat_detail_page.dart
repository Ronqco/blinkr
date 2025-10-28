import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/config/app_config.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({super.key, required this.chatId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _canSendMessage = true;
  int _messagesRemaining = 50;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConfig.adUnitIdAndroid,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('[v0] Failed to load rewarded ad: $error');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anuncio no disponible')),
      );
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          _messagesRemaining += AppConfig.messagesUnlockedPerAd;
          _canSendMessage = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡${AppConfig.messagesUnlockedPerAd} mensajes desbloqueados!',
            ),
          ),
        );
        _loadRewardedAd(); // Load next ad
      },
    );

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    if (!_canSendMessage) {
      _showMessageLimitDialog();
      return;
    }

    // TODO: Send message via BLoC
    setState(() {
      _messagesRemaining--;
      if (_messagesRemaining <= 0) {
        _canSendMessage = false;
      }
    });

    _messageController.clear();
  }

  void _showMessageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Límite de mensajes alcanzado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Has alcanzado tu límite diario de mensajes gratuitos.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Opciones:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.ads_click),
                title: const Text('Ver anuncio'),
                subtitle: Text(
                  '+${AppConfig.messagesUnlockedPerAd} mensajes',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showRewardedAd();
                },
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text('Blinkr Premium'),
                subtitle: const Text('Mensajes ilimitados'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to premium page
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 16),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario', style: TextStyle(fontSize: 16)),
                  Text(
                    'En línea',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message limit indicator
          if (!_canSendMessage || _messagesRemaining < 10)
            Container(
              padding: const EdgeInsets.all(12),
              color: _canSendMessage
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _canSendMessage ? Icons.warning_amber : Icons.block,
                    color: _canSendMessage ? Colors.orange : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _canSendMessage
                          ? 'Te quedan $_messagesRemaining mensajes hoy'
                          : 'Límite alcanzado. Ve un anuncio o hazte Premium',
                      style: TextStyle(
                        fontSize: 12,
                        color: _canSendMessage ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  if (!_canSendMessage)
                    TextButton(
                      onPressed: _showMessageLimitDialog,
                      child: const Text('Ver opciones'),
                    ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: 0, // TODO: Get from BLoC
              itemBuilder: (context, index) {
                return const SizedBox(); // Message bubble
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
