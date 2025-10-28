import 'package:flutter/material.dart';
import '../../../../core/services/ad_service.dart';
import '../../../premium/presentation/pages/premium_upgrade_page.dart';

class MessageLimitBanner extends StatelessWidget {
  final int remainingMessages;
  final VoidCallback onMessagesUnlocked;

  const MessageLimitBanner({
    super.key,
    required this.remainingMessages,
    required this.onMessagesUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (remainingMessages > 10) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: remainingMessages == 0 ? Colors.red.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: remainingMessages == 0 ? Colors.red : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                remainingMessages == 0 ? Icons.block : Icons.warning,
                color: remainingMessages == 0 ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  remainingMessages == 0
                      ? 'No messages remaining today'
                      : '$remainingMessages messages remaining today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: remainingMessages == 0 ? Colors.red.shade900 : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final adService = AdService();
                    if (adService.isRewardedAdReady) {
                      final success = await adService.showRewardedAd();
                      if (success) {
                        onMessagesUnlocked();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('10 messages unlocked!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ad not ready, please try again'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Watch Ad (+10)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumUpgradePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Go Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
