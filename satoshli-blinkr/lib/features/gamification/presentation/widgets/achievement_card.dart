import 'package:flutter/material.dart';
import '../../domain/entities/achievement_entity.dart';

class AchievementCard extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: achievement.isUnlocked 
                      ? Colors.amber 
                      : Colors.grey[400],
                ),
                if (!achievement.isUnlocked)
                  Icon(
                    Icons.lock,
                    size: 32,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked 
                    ? Colors.black 
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${achievement.requiredXp} XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked 
                    ? Colors.green 
                    : Colors.grey[600],
              ),
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
