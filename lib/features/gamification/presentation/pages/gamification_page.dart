import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/interest_categories.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';
import '../widgets/xp_card.dart';
import '../widgets/achievement_card.dart';

class GamificationPage extends StatefulWidget {
  final String userId;

  const GamificationPage({super.key, required this.userId});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<GamificationBloc>().add(LoadUserXp(widget.userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My XP'),
            Tab(text: 'Achievements'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyXpTab(),
          _buildAchievementsTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  Widget _buildMyXpTab() {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, state) {
        if (state is GamificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserXpLoaded) {
          if (state.userXp.isEmpty) {
            return const Center(
              child: Text('Start interacting to earn XP!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.userXp.length,
            itemBuilder: (context, index) {
              final xp = state.userXp[index];
              final category = InterestCategories.allCategories
                  .firstWhere((c) => c.id == xp.categoryId);

              return XpCard(
                userXp: xp,
                category: category,
              );
            },
          );
        }

        if (state is GamificationError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAchievementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategoryId,
            items: InterestCategories.allCategories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategoryId = value);
                context.read<GamificationBloc>().add(
                  LoadAchievements(widget.userId, value),
                );
              }
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<GamificationBloc, GamificationState>(
            builder: (context, state) {
              if (state is GamificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AchievementsLoaded) {
                if (state.achievements.isEmpty) {
                  return const Center(
                    child: Text('No achievements available for this category'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: state.achievements.length,
                  itemBuilder: (context, index) {
                    return AchievementCard(
                      achievement: state.achievements[index],
                    );
                  },
                );
              }

              if (state is GamificationError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              return const Center(
                child: Text('Select a category to view achievements'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategoryId,
            items: InterestCategories.allCategories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategoryId = value);
                context.read<GamificationBloc>().add(
                  LoadLeaderboard(value),
                );
              }
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<GamificationBloc, GamificationState>(
            builder: (context, state) {
              if (state is GamificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LeaderboardLoaded) {
                if (state.leaderboard.isEmpty) {
                  return const Center(
                    child: Text('No leaderboard data available'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.leaderboard.length,
                  itemBuilder: (context, index) {
                    final xp = state.leaderboard[index];
                    final rank = index + 1;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rank <= 3 
                              ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown)
                              : Colors.blue,
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text('User ${xp.userId.substring(0, 8)}'),
                        subtitle: Text('Level ${xp.level}'),
                        trailing: Text(
                          '${xp.xp} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is GamificationError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              return const Center(
                child: Text('Select a category to view leaderboard'),
              );
            },
          ),
        ),
      ],
    );
  }
}
