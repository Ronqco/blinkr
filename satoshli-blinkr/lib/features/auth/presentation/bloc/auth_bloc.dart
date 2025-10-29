import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;  // ← CAMBIAR ESTA LÍNEA
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUpdateInterests>(_onUpdateInterests);
  }

  Future<void> _onUpdateInterests(
    AuthUpdateInterests event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final client = supabase.Supabase.instance.client;  // ← CAMBIAR
      final userId = client.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const AuthError('Usuario no autenticado'));
        return;
      }

      // Eliminar intereses anteriores
      await client
          .from('user_interests')
          .delete()
          .eq('user_id', userId);

      // Insertar nuevos intereses
      if (event.interests.isNotEmpty) {
        final interestsData = event.interests
            .map((categoryId) => {
                  'user_id': userId,
                  'category_id': categoryId,
                })
            .toList();

        await client.from('user_interests').insert(interestsData);
      }

      // Mantener el estado actual
      if (state is AuthAuthenticated) {
        emit(state);
      }
    } catch (e) {
      emit(AuthError('Error actualizando intereses: $e'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    emit(AuthUnauthenticated());
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      email: event.email,
      password: event.password,
      username: event.username,
      displayName: event.displayName,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
