import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'TU_SUPABASE_URL_AQUI',
    anonKey: 'TU_SUPABASE_ANON_KEY_AQUI',
  );
  
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Supabase')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                // Test: obtener categorías de interés
                final response = await Supabase.instance.client
                    .from('interest_categories')
                    .select()
                    .limit(5);
                
                print('✅ Conexión exitosa!');
                print('Categorías: $response');
              } catch (e) {
                print('❌ Error: $e');
              }
            },
            child: const Text('Probar Conexión'),
          ),
        ),
      ),
    );
  }
}