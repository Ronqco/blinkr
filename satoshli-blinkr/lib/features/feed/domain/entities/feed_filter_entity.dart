import 'package:equatable/equatable.dart';

class FeedFilterEntity extends Equatable {
  final String postType; // 'all', 'post', 'short', 'thread'
  final String? categoryId;
  final bool showNSFW;
  final String sortBy; // 'recent', 'trending', 'recommended'

  const FeedFilterEntity({
    this.postType = 'all',
    this.categoryId,
    this.showNSFW = false,
    this.sortBy = 'recommended',
  });

  @override
  List<Object?> get props => [postType, categoryId, showNSFW, sortBy];
}
