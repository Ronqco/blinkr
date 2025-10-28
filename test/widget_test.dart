import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:blinkr/main.dart';
import 'package:blinkr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blinkr/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:blinkr/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:blinkr/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:blinkr/features/gamification/presentation/bloc/gamification_bloc.dart';

// ----------------- MOCKS -----------------
class MockAuthBloc extends Mock implements AuthBloc {}
class MockDiscoveryBloc extends Mock implements DiscoveryBloc {}
class MockFeedBloc extends Mock implements FeedBloc {}
class MockChatBloc extends Mock implements ChatBloc {}
class MockGamificationBloc extends Mock implements GamificationBloc {}

// Fake States
class FakeAuthState extends Fake implements AuthState {}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    // Registra el fallback para estados falsos
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    // Limpia las dependencias registradas en GetIt antes de cada prueba
    sl.reset();

    // Crea y configura el mock de AuthBloc
    final mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(FakeAuthState());
    whenListen(
      mockAuthBloc,
      Stream<AuthState>.fromIterable([FakeAuthState()]),
    );

    // Registra todos los mocks en GetIt
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
    sl.registerFactory<DiscoveryBloc>(() => MockDiscoveryBloc());
    sl.registerFactory<FeedBloc>(() => MockFeedBloc());
    sl.registerFactory<ChatBloc>(() => MockChatBloc());
    sl.registerFactory<GamificationBloc>(() => MockGamificationBloc());
  });

  testWidgets('Verifica el contador de la app', (WidgetTester tester) async {
    // Inicia la aplicación
    await tester.pumpWidget(const BlinkrApp());

    // Verifica que el texto '0' esté presente y '1' no lo esté
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simula un toque en el ícono de incremento
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que el texto '1' ahora esté presente y '0' no
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
