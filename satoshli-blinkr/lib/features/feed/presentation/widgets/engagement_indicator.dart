import 'package:flutter/material.dart';

class EngagementIndicator extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final double engagementScore;

  const EngagementIndicator({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.engagementScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMetric('❤️', likesCount),
          const SizedBox(width: 12),
          _buildMetric('💬', commentsCount),
          const SizedBox(width: 12),
          _buildMetric('📤', sharesCount),
          const SizedBox(width: 12),
          _buildEngagementBadge(),
        ],
      ),
    );
  }

  Widget _buildMetric(String icon, int count) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEngagementBadge() {
    String label;
    Color color;

    if (engagementScore > 100) {
      label = '🔥 Viral';
      color = Colors.red;
    } else if (engagementScore > 50) {
      label = '⭐ Trending';
      color = Colors.orange;
    } else if (engagementScore > 10) {
      label = '👍 Popular';
      color = Colors.blue;
    } else {
      label = '📌 Nuevo';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
