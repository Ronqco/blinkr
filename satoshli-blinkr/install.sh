#!/bin/bash

# BLINKR - Installation Script v2.0
# Este script automatiza la instalación completa de Blinkr

set -e

echo "🚀 BLINKR - Complete Installation Script v2.0"
echo "=============================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado"
    echo "Descárgalo desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

print_status "Flutter encontrado: $(flutter --version | head -n 1)"

# Verificar si Git está instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado"
    exit 1
fi

print_status "Git encontrado"

# Limpiar proyecto anterior
echo ""
echo "Limpiando proyecto..."
flutter clean
print_status "Proyecto limpiado"

# Obtener dependencias
echo ""
echo "Descargando dependencias..."
flutter pub get
print_status "Dependencias descargadas"

# Actualizar dependencias
echo ""
echo "Actualizando dependencias..."
flutter pub upgrade
print_status "Dependencias actualizadas"

# Generar archivos de configuración
echo ""
echo "Generando archivos de configuración..."
flutter pub run build_runner build --delete-conflicting-outputs
print_status "Archivos generados"

# Verificar compilación
echo ""
echo "Verificando compilación..."
flutter analyze
print_status "Análisis completado"

# Información de configuración
echo ""
echo "=============================================="
echo -e "${GREEN}✓ Instalación completada exitosamente${NC}"
echo "=============================================="
echo ""
echo "Próximos pasos:"
echo "1. Configura Firebase:"
echo "   - Descarga google-services.json (Android)"
echo "   - Descarga GoogleService-Info.plist (iOS)"
echo ""
echo "2. Configura Supabase:"
echo "   - Copia credenciales en lib/core/config/app_config.dart"
echo ""
echo "3. Ejecuta las migraciones SQL en Supabase"
echo ""
echo "4. Ejecuta la app:"
echo "   flutter run"
echo ""
echo "Para más información, consulta BLINKR_COMPLETE_PACKAGE.md"
