import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/router/app_router.dart';
import 'core/services/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';  // ← AGREGADO
import 'features/discovery/presentation/bloc/discovery_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  print("Supabase URL: ${dotenv.env['SUPABASE_URL']}"); // Verifica que la URL se cargue correctamente
  print("Supabase Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']}"); // Verifica que la clave se cargue correctamente
  
  AppConfig.validateConfig();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize Mobile Ads
  await MobileAds.instance.initialize();
  
  // Setup Service Locator (Dependency Injection)
  await setupServiceLocator();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const BlinkrApp());
}

class BlinkrApp extends StatelessWidget {
  const BlinkrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested())),  // ← CORRECTO
        BlocProvider(create: (_) => getIt<DiscoveryBloc>()),
        BlocProvider(create: (_) => getIt<FeedBloc>()),
        BlocProvider(create: (_) => getIt<ChatBloc>()),
        BlocProvider(create: (_) => getIt<GamificationBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Blinkr',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}