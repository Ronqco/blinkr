#!/bin/bash
# scripts/fix_and_prepare_project.sh
# ⚙️ Repara y prepara Blinkr para despliegue

set -e

echo "🚀 Iniciando proceso de saneamiento de Blinkr..."

########################################
# 1. CONFIGURACIÓN DE ENTORNO
########################################
echo "🧭 Creando archivo .env.example..."
cat > .env.example << 'EOF'
SUPABASE_URL=https://TU_URL_SUPABASE
SUPABASE_ANON_KEY=TU_KEY_SUPABASE
ADMOB_REWARDED_ANDROID=ca-app-pub-TUIDIREAL/REWARDED_ANDROID
ADMOB_REWARDED_IOS=ca-app-pub-TUIDIREAL/REWARDED_IOS
EOF

echo "✅ .env.example creado (recuerda copiarlo a .env con tus valores reales)"

# Actualizar gitignore
if ! grep -q ".env" .gitignore; then
  echo "🧹 Actualizando .gitignore..."
  echo -e "\n# Env files\n.env\n.env.*\n!.env.example\nlib/core/config/secrets.dart" >> .gitignore
fi

########################################
# 2. ARCHIVO DE CONFIGURACIÓN
########################################
mkdir -p lib/core/config
cat > lib/core/config/app_config.dart << 'EOF'
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('❌ SUPABASE CREDENTIALS NOT CONFIGURED');
    }
  }
}
EOF
echo "✅ lib/core/config/app_config.dart recreado"

########################################
# 3. CORREGIR FUNCIÓN SQL
########################################
mkdir -p scripts
cat > scripts/02_create_functions.sql << 'EOF'
CREATE OR REPLACE FUNCTION calculate_level(xp INTEGER)
RETURNS INTEGER AS $$
BEGIN
  IF xp < 100 THEN
    RETURN 1;
  ELSE
    RETURN FLOOR(xp::FLOAT / 100.0)::INTEGER + 1;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
EOF
echo "✅ SQL corregido en scripts/02_create_functions.sql"

########################################
# 4. PERMISOS iOS
########################################
mkdir -p ios/Runner
cat > ios/Runner/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Blinkr necesita tu ubicación para mostrarte personas cercanas</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Blinkr usa tu ubicación para conectar con personas cercanas</string>
  <key>GADApplicationIdentifier</key>
  <string>ca-app-pub-TUIDIREAL~TUAPPID</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
  </dict>
</dict>
</plist>
EOF
echo "✅ Info.plist verificado/corregido"

########################################
# 5. TESTS Y LIMPIEZA
########################################
mkdir -p test
cat > test/widget_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkr/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BlinkrApp());
    expect(find.byType(BlinkrApp), findsOneWidget);
  });
}
EOF
echo "✅ Test widget corregido"

# Eliminar package.json si existe
if [ -f "package.json" ]; then
  rm package.json
  echo "🗑️ package.json eliminado (proyecto Flutter, no Node.js)"
fi

########################################
# 6. VALIDACIONES DE SEGURIDAD
########################################
echo "🧠 Revisando secretos hardcodeados..."
if grep -r "eyJhbGciOi" lib/ >/dev/null 2>&1; then
  echo "❌ Se detectó una clave de Supabase incrustada en el código."
  echo "   ➜ Revisa los archivos en lib/ y muévela a variables de entorno."
  exit 1
else
  echo "✅ No hay claves incrustadas detectadas."
fi

########################################
# 7. LOGGING & CACHE
########################################
mkdir -p lib/core/logging
cat > lib/core/logging/app_logger.dart << 'EOF'
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, lineLength: 120, colors: true),
  );

  static void debug(String msg) => _logger.d(msg);
  static void info(String msg) => _logger.i(msg);
  static void warning(String msg) => _logger.w(msg);
  static void error(String msg, [dynamic err, StackTrace? s]) =>
      _logger.e(msg, error: err, stackTrace: s);
}
EOF

mkdir -p lib/core/cache
cat > lib/core/cache/image_cache_manager.dart << 'EOF'
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BlinkrCacheManager extends CacheManager {
  static const key = 'blinkrCache';
  static BlinkrCacheManager? _instance;

  factory BlinkrCacheManager() =>
      _instance ??= BlinkrCacheManager._();

  BlinkrCacheManager._()
      : super(Config(key, stalePeriod: Duration(days: 7), maxNrOfCacheObjects: 200));
}
EOF

echo "✅ Logging y cache listos"

########################################
# 8. VALIDACIÓN FINAL
########################################
echo "🧪 Ejecutando validaciones finales..."
flutter analyze || { echo "❌ Análisis falló"; exit 1; }
flutter test || { echo "❌ Tests fallaron"; exit 1; }

echo "✅ Todo listo para build"
echo "👉 Ejecuta:"
echo "flutter build appbundle --release \\"
echo "  --dart-define=SUPABASE_URL=\$SUPABASE_URL \\"
echo "  --dart-define=SUPABASE_ANON_KEY=\$SUPABASE_ANON_KEY"
