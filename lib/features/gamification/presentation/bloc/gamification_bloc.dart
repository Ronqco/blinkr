import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_xp_usecase.dart';
import '../../domain/usecases/add_xp_usecase.dart';
import '../../domain/repositories/gamification_repository.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GetUserXpUseCase getUserXpUseCase;
  final AddXpUseCase addXpUseCase;
  final GamificationRepository repository;

  GamificationBloc({
    required this.getUserXpUseCase,
    required this.addXpUseCase,
    required this.repository,
  }) : super(GamificationInitial()) {
    on<LoadUserXp>(_onLoadUserXp);
    on<LoadCategoryXp>(_onLoadCategoryXp);
    on<AddXp>(_onAddXp);
    on<LoadAchievements>(_onLoadAchievements);
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadUserXp(LoadUserXp event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    final result = await getUserXpUseCase(event.userId);
    result.fold(
      (failure) => emit(GamificationError(failure.toString())),
      (userXp) => emit(UserXpLoaded(userXp)),
    );
  }

  Future<void> _onLoadCategoryXp(LoadCategoryXp event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    final result = await repository.getCategoryXp(event.userId, event.categoryId);
    result.fold(
      (failure) => emit(GamificationError(failure.toString())),
      (categoryXp) => emit(CategoryXpLoaded(categoryXp)),
    );
  }

  Future<void> _onAddXp(AddXp event, Emitter<GamificationState> emit) async {
    final result = await addXpUseCase(event.userId, event.categoryId, event.xp);
    result.fold(
      (failure) => emit(GamificationError(failure.toString())),
      (_) => emit(XpAdded('XP added successfully!')),
    );
  }

  Future<void> _onLoadAchievements(LoadAchievements event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    final result = await repository.getUserAchievements(event.userId, event.categoryId);
    result.fold(
      (failure) => emit(GamificationError(failure.toString())),
      (achievements) => emit(AchievementsLoaded(achievements)),
    );
  }

  Future<void> _onLoadLeaderboard(LoadLeaderboard event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    final result = await repository.getLeaderboard(event.categoryId);
    result.fold(
      (failure) => emit(GamificationError(failure.toString())),
      (leaderboard) => emit(LeaderboardLoaded(leaderboard)),
    );
  }
}
