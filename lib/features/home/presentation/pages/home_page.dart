import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/interest_categories.dart';
import '../../../feed/presentation/pages/competitive_feed_page.dart';
import '../../../discovery/presentation/pages/discovery_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

/// 🏠 Página principal con 5 tabs
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // ✅ Tabs
  final List<Widget> _pages = const [
    ForYouFeedTab(),
    DiscoveryPage(),
    CompetitiveFeedPage(),
    ChatListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'For You',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Battles',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// 🎯 Tab “For You” con feed algorítmico
class ForYouFeedTab extends StatefulWidget {
  const ForYouFeedTab({super.key});

  @override
  State<ForYouFeedTab> createState() => _ForYouFeedTabState();
}

class _ForYouFeedTabState extends State<ForYouFeedTab> {
  String _selectedFilter = 'all';
  late List<Map<String, dynamic>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _generateAlgorithmicFeed();
  }

  /// 🧠 Simulación de algoritmo de recomendación
  /// Basado en intereses, cercanía, engagement y antigüedad
  List<Map<String, dynamic>> _generateAlgorithmicFeed() {
    final now = DateTime.now();
    final randomPosts = InterestCategories.all.map((cat) {
      final engagementScore = (cat.id.hashCode % 100) / 100.0;
      final timeDecay = 1.0 - ((cat.id.hashCode % 48) / 100.0);
      final proximityBoost = cat.isNSFW ? 0.7 : 1.0;

      final score = engagementScore * 0.5 + timeDecay * 0.3 + proximityBoost * 0.2;

      return {
        'category': cat,
        'title': 'Post sobre ${cat.name}',
        'likes': (score * 1000).round(),
        'createdAt': now.subtract(Duration(hours: cat.id.hashCode % 48)),
        'score': score,
      };
    }).toList();

    randomPosts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return randomPosts;
  }

  List<Map<String, dynamic>> _filterPosts(String filter) {
    switch (filter) {
      case 'trending':
        return _posts.where((p) => p['likes'] > 400).toList();
      case 'new':
        return _posts
            .where((p) =>
                DateTime.now().difference(p['createdAt']).inHours < 12)
            .toList();
      case 'interests':
        return _posts.where((p) => !p['category'].isNSFW).toList();
      case 'nearby':
        return _posts
            .where((p) => p['category'].name.contains('Local') || p['category'].name.contains('Chile'))
            .toList();
      default:
        return _posts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _filterPosts(_selectedFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 800));
                setState(() {
                  _posts = _generateAlgorithmicFeed();
                });
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  final category = post['category'] as InterestCategory;
                  return _buildPostCard(category, post);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = [
      {'label': 'Todos', 'value': 'all'},
      {'label': '🔥 Trending', 'value': 'trending'},
      {'label': '🆕 Nuevos', 'value': 'new'},
      {'label': '🎯 Tus Intereses', 'value': 'interests'},
      {'label': '👥 Cercanos', 'value': 'nearby'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return FilterChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter['value']!;
              });
            },
            backgroundColor: Colors.transparent,
            selectedColor:
                Theme.of(context).colorScheme.primary.withValues(alpha : 0.2),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(InterestCategory category, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => context.push('/feed/${category.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category.isNSFW
                        ? [
                            const Color(0xFFE67E22).withValues(alpha : 0.7),
                            const Color(0xFFE67E22).withValues(alpha : 0.9),
                          ]
                        : [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha : 0.7),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha : 0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(category.icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'],
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('${post['likes']} likes',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
