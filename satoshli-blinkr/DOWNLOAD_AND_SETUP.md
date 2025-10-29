# 📥 DESCARGA E INSTALACIÓN - BLINKR v2.0

## Opción 1: Descargar ZIP (Recomendado)

### Paso 1: Descargar
1. Haz clic en el botón **"Download ZIP"** en la esquina superior derecha
2. Espera a que se descargue `blinkr-complete-v2.0.zip`
3. Extrae el archivo en tu directorio de proyectos

### Paso 2: Instalar Dependencias
\`\`\`bash
cd blinkr
flutter pub get
\`\`\`

### Paso 3: Ejecutar Script de Instalación
\`\`\`bash
# En macOS/Linux
chmod +x install.sh
./install.sh

# En Windows
install.bat
\`\`\`

### Paso 4: Configurar Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Crea un nuevo proyecto
3. Descarga `google-services.json` (Android)
4. Descarga `GoogleService-Info.plist` (iOS)
5. Coloca los archivos en:
   - Android: `android/app/`
   - iOS: `ios/Runner/`

### Paso 5: Configurar Supabase
1. Ve a [Supabase](https://supabase.com)
2. Crea un nuevo proyecto
3. Copia la URL y la clave anónima
4. Abre `lib/core/config/app_config.dart`
5. Reemplaza:
   \`\`\`dart
   static const String supabaseUrl = 'TU_URL_AQUI';
   static const String supabaseAnonKey = 'TU_CLAVE_AQUI';
   \`\`\`

### Paso 6: Ejecutar Migraciones
1. Abre Supabase SQL Editor
2. Copia y ejecuta los scripts de `BLINKR_COMPLETE_PACKAGE.md`
3. Verifica que todas las tablas se crearon

### Paso 7: Ejecutar la App
\`\`\`bash
flutter run
\`\`\`

---

## Opción 2: Clonar desde GitHub

### Paso 1: Clonar Repositorio
\`\`\`bash
git clone https://github.com/Satoshli/blinkr.git
cd blinkr
\`\`\`

### Paso 2: Instalar Dependencias
\`\`\`bash
flutter pub get
\`\`\`

### Paso 3-7: Seguir los mismos pasos que la Opción 1

---

## Opción 3: Usar CLI de shadcn

### Paso 1: Instalar shadcn CLI
\`\`\`bash
npm install -g shadcn-cli
\`\`\`

### Paso 2: Crear Proyecto
\`\`\`bash
shadcn-cli init blinkr
cd blinkr
\`\`\`

### Paso 3-7: Seguir los mismos pasos que la Opción 1

---

## 🔍 VERIFICACIÓN DE INSTALACIÓN

Ejecuta estos comandos para verificar que todo está bien:

\`\`\`bash
# Verificar Flutter
flutter doctor

# Verificar dependencias
flutter pub get

# Analizar código
flutter analyze

# Ejecutar tests
flutter test
\`\`\`

---

## 📱 EJECUTAR EN DISPOSITIVO

### Android
\`\`\`bash
flutter run -d android
\`\`\`

### iOS
\`\`\`bash
flutter run -d ios
\`\`\`

### Web
\`\`\`bash
flutter run -d web
\`\`\`

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "Flutter not found"
- Instala Flutter desde https://flutter.dev/docs/get-started/install
- Agrega Flutter al PATH

### Error: "Gradle build failed"
- Ejecuta: \`flutter clean\`
- Ejecuta: \`flutter pub get\`
- Intenta de nuevo

### Error: "Firebase not configured"
- Verifica que google-services.json está en android/app/
- Verifica que GoogleService-Info.plist está en ios/Runner/

### Error: "Supabase connection failed"
- Verifica la URL y la clave en app_config.dart
- Verifica que Supabase está en línea
- Verifica la conexión a internet

### Las notificaciones no funcionan
- Verifica que Firebase está configurado
- Verifica permisos en AndroidManifest.xml
- Ejecuta en un dispositivo real (no emulador)

---

## 📊 ESTRUCTURA DE CARPETAS

\`\`\`
blinkr/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   ├── config/
│   │   ├── router/
│   │   └── ...
│   ├── features/
│   │   ├── auth/
│   │   ├── feed/
│   │   ├── chat/
│   │   ├── profile/
│   │   ├── search/
│   │   └── ...
│   ├── main.dart
│   └── firebase_options.dart
├── android/
├── ios/
├── web/
├── pubspec.yaml
├── pubspec.lock
├── install.sh
├── install.bat
└── README.md
\`\`\`

---

## 🚀 PRÓXIMOS PASOS

1. **Personaliza la app:**
   - Cambia colores en `lib/core/config/theme_config.dart`
   - Cambia nombre en `pubspec.yaml`
   - Cambia iconos en `assets/`

2. **Agrega tu contenido:**
   - Crea posts de ejemplo
   - Invita usuarios
   - Configura moderación

3. **Despliega a producción:**
   - Genera APK: \`flutter build apk\`
   - Genera IPA: \`flutter build ios\`
   - Sube a Google Play y App Store

---

## 📞 SOPORTE

Si tienes problemas:
1. Consulta [Flutter Docs](https://flutter.dev/docs)
2. Consulta [Firebase Docs](https://firebase.google.com/docs)
3. Consulta [Supabase Docs](https://supabase.com/docs)
4. Abre un issue en GitHub

---

**¡Listo para comenzar! 🎉**
