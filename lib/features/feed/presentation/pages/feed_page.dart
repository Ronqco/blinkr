import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/interest_categories.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../../domain/entities/post_entity.dart';

class FeedPage extends StatefulWidget {
  final String categoryId;

  const FeedPage({super.key, required this.categoryId});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(FeedLoadPosts(categoryId: widget.categoryId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<FeedBloc>().state;
      if (state is FeedLoaded && state.hasMore) {
        _currentPage++;
        context.read<FeedBloc>().add(
              FeedLoadPosts(categoryId: widget.categoryId, page: _currentPage),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = InterestCategories.getById(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Text(category.icon),
              const SizedBox(width: 8),
            ],
            Text(category?.name ?? 'Feed'),
          ],
        ),
        actions: [
          if (category?.isNSFW == true)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE67E22),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '18+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      context
                          .read<FeedBloc>()
                          .add(FeedLoadPosts(categoryId: widget.categoryId));
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.post_add, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No hay publicaciones aún'),
                    const SizedBox(height: 8),
                    Text(
                      'Sé el primero en publicar',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _currentPage = 0;
                context.read<FeedBloc>().add(FeedRefresh(widget.categoryId));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _buildPostCard(context, state.posts[index]);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context, category),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostEntity post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.avatarUrl != null
                  ? CachedNetworkImageProvider(post.avatarUrl!)
                  : null,
              child: post.avatarUrl == null
                  ? Text(post.displayName[0].toUpperCase())
                  : null,
            ),
            title: Text(
              post.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(timeago.format(post.createdAt, locale: 'es')),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showPostOptions(context, post),
            ),
          ),

          // NSFW Warning
          if (post.isNSFW) _buildNSFWWarning(context, post),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                Text(post.content),
              ],
            ),
          ),

          // Post images
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
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
          ],

          // Post actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.isLikedByMe ? Colors.red : null,
                  ),
                  onPressed: () async {
                    // Dar like
                    context.read<FeedBloc>().add(FeedToggleLike(post.id));
                    
                    // Esperar un momento y recargar
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (context.mounted) {
                      context.read<FeedBloc>().add(FeedRefresh(widget.categoryId));
                    }
                  },
                ),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // TODO: Navigate to comments
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comentarios - Próximamente')),
                    );
                  },
                ),
                Text('${post.commentsCount}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartir - Próximamente')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNSFWWarning(BuildContext context, PostEntity post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE67E22).withOpacity(0.1),
        border: Border.all(color: const Color(0xFFE67E22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE67E22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contenido sensible (18+)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE67E22),
                  ),
                ),
                if (post.nsfwWarning != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.nsfwWarning!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context, InterestCategory? category) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    bool isNSFW = category?.isNSFW ?? false;
    String? nsfwWarning;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Crear Publicación'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Escribe un título llamativo',
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Contenido',
                        hintText: 'Comparte tu historia...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      maxLength: 1000,
                    ),
                    if (category?.isNSFW == true) ...[
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Contenido NSFW'),
                        subtitle: const Text('Marca si contiene contenido adulto'),
                        value: isNSFW,
                        onChanged: (value) {
                          setState(() {
                            isNSFW = value ?? false;
                          });
                        },
                      ),
                      if (isNSFW) ...[
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Advertencia (opcional)',
                            hintText: 'Ej: Desnudos artísticos',
                          ),
                          onChanged: (value) {
                            nsfwWarning = value;
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Título y contenido son requeridos'),
                        ),
                      );
                      return;
                    }

                    // Crear post
                    this.context.read<FeedBloc>().add(
                          FeedCreatePost(
                            categoryId: widget.categoryId,
                            title: titleController.text.trim(),
                            content: contentController.text.trim(),
                            isNSFW: isNSFW,
                            nsfwWarning: nsfwWarning,
                          ),
                        );

                    Navigator.pop(dialogContext);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Publicación creada'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Recargar feed
                    _currentPage = 0;
                    this.context.read<FeedBloc>().add(FeedRefresh(widget.categoryId));
                  },
                  child: const Text('Publicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, PostEntity post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Reportar'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context, post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Bloquear usuario'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario bloqueado')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, PostEntity post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reportar publicación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Por qué reportas esta publicación?'),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Spam'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reporte enviado')),
                  );
                },
              ),
              ListTile(
                title: const Text('Contenido inapropiado'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reporte enviado')),
                  );
                },
              ),
              ListTile(
                title: const Text('Acoso o bullying'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reporte enviado')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}