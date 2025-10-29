import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_recommendations_usecase.dart';
import '../../domain/repositories/recommendation_repository.dart';
import 'recommendation_event.dart';
import 'recommendation_state.dart';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final GetUserRecommendationsUseCase getUserRecommendationsUseCase;
  final RecommendationRepository repository;

  RecommendationBloc({
    required this.getUserRecommendationsUseCase,
    required this.repository,
  }) : super(RecommendationInitial()) {
    on<RecommendationLoadRecommendations>(_onLoadRecommendations);
    on<RecommendationUpdateScore>(_onUpdateScore);
  }

  Future<void> _onLoadRecommendations(
    RecommendationLoadRecommendations event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoading());

    final result = await getUserRecommendationsUseCase();

    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (recommendations) => emit(RecommendationLoaded(recommendations)),
    );
  }

  Future<void> _onUpdateScore(
    RecommendationUpdateScore event,
    Emitter<RecommendationState> emit,
  ) async {
    final result = await repository.updateUserInterestScore(
      interestId: event.interestId,
      likesCount: event.likesCount,
    );

    result.fold(
      (failure) => emit(RecommendationError(failure.message)),
      (_) {
        // Recargar recomendaciones después de actualizar
        add(RecommendationLoadRecommendations());
      },
    );
  }
}
