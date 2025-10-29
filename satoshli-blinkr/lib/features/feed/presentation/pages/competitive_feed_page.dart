// 🔧 NUEVO: Pantalla de feed competitivo

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/interest_categories.dart';
import '../../domain/entities/competitive_post_entity.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';

class CompetitiveFeedPage extends StatefulWidget {
  final String? categoryId;

  const CompetitiveFeedPage({super.key, this.categoryId});

  @override
  State<CompetitiveFeedPage> createState() => _CompetitiveFeedPageState();
}

class _CompetitiveFeedPageState extends State<CompetitiveFeedPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // ✅ NUEVO: Cargar feed competitivo
    context.read<FeedBloc>().add(
      FeedLoadCompetitive(categoryId: widget.categoryId),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.categoryId != null 
        ? InterestCategories.getById(widget.categoryId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥 '),
            Text(category?.name ?? 'Top Posts'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FeedBloc>().add(
                FeedLoadCompetitive(categoryId: widget.categoryId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeedError) {
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
                      context.read<FeedBloc>().add(
                        FeedLoadCompetitive(categoryId: widget.categoryId),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedCompetitiveLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No hay posts en el ranking aún'),
                    SizedBox(height: 8),
                    Text('¡Sé el primero en publicar!'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(
                  FeedLoadCompetitive(categoryId: widget.categoryId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return _buildCompetitivePostCard(
                    context, 
                    state.posts[index],
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCompetitivePostCard(
    BuildContext context,
    CompetitivePostEntity competitivePost,
  ) {
    final post = competitivePost.post;
    final isTopThree = competitivePost.rank <= 3;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isTopThree ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTopThree
            ? BorderSide(
                color: _getRankColor(competitivePost.rank),
                width: 3,
              )
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ NUEVO: Header con ranking
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? LinearGradient(
                      colors: [
                        _getRankColor(competitivePost.rank).withValues(alpha : 0.3),
                        _getRankColor(competitivePost.rank).withValues(alpha : 0.1),
                      ],
                    )
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Medalla animada para top 3
                if (isTopThree)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Text(
                      competitivePost.medalIcon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${competitivePost.rank}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundImage: post.avatarUrl != null
                      ? CachedNetworkImageProvider(post.avatarUrl!)
                      : null,
                  child: post.avatarUrl == null
                      ? Text(post.displayName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeago.format(post.createdAt, locale: 'es'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha : 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.whatshot,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${competitivePost.finalScore.toStringAsFixed(1)} pts',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido del post
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Imágenes
          if (post.imageUrls.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrls[index],
                        width: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Acciones con métricas
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildMetricButton(
                  icon: post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  count: post.likesCount,
                  color: post.isLikedByMe ? Colors.red : null,
                  onPressed: () {
                    context.read<FeedBloc>().add(FeedToggleLike(post.id));
                  },
                ),
                const SizedBox(width: 16),
                _buildMetricButton(
                  icon: Icons.comment_outlined,
                  count: post.commentsCount,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comentarios - Próximamente')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildMetricButton(
                  icon: Icons.share_outlined,
                  count: competitivePost.sharesCount,
                  onPressed: () {
                    context.read<FeedBloc>().add(FeedSharePost(post.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post compartido'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                const Spacer(),
                if (isTopThree)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRankColor(competitivePost.rank),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TOP ${competitivePost.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricButton({
    required IconData icon,
    required int count,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}
