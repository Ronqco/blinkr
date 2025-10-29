// 📁 lib/features/feed/domain/entities/competitive_post_entity.dart
import 'package:equatable/equatable.dart';
import 'post_entity.dart';

class CompetitivePostEntity extends Equatable {
  final PostEntity post;
  final int rank;
  final double finalScore;
  final int sharesCount;
  final DateTime rankingDate;

  const CompetitivePostEntity({
    required this.post,
    required this.rank,
    required this.finalScore,
    required this.sharesCount,
    required this.rankingDate,
  });

  String get medalIcon {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        post,
        rank,
        finalScore,
        sharesCount,
        rankingDate,
      ];
}
