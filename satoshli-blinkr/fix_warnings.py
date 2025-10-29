#!/usr/bin/env python3
"""
Script para corregir automáticamente warnings de Flutter
Uso: python fix_warnings.py
"""

import os
import re
from pathlib import Path

def fix_with_opacity(content: str) -> str:
    """Reemplaza .withOpacity(X) por .withValues(alpha: X)"""
    pattern = r'.withOpacity(([0-9.]+))'
    replacement = r'.withValues(alpha: \1)'
    return re.sub(pattern, replacement, content)

def fix_print_statements(content: str) -> str:
    """Comenta print statements para debugging"""
    lines = content.split('\n')
    fixed_lines = []
    for line in lines:
        # Si la línea contiene print y no está comentada
        if 'print(' in line and not line.strip().startswith('//'):
            # Comentar la línea
            indent = len(line) - len(line.lstrip())
            fixed_lines.append(' ' * indent + '// ' + line.lstrip() + ' // ⚠️ Descomentado por script')
        else:
            fixed_lines.append(line)
    return '\n'.join(fixed_lines)

def remove_unused_field(content: str, field_name: str) -> str:
    """Elimina un campo no usado"""
    # Buscar la declaración del campo
    pattern = rf'late\s+AnimationController\s+{field_name};'
    content = re.sub(pattern, f'// {field_name} removido (no usado)', content)
    # Buscar la inicialización
    pattern = rf'{field_name}\s*=\s*Tween.*?\.animate\([^)]*\);'
    content = re.sub(pattern, '', content, flags=re.DOTALL)
    return content

def fix_unnecessary_null_assertion(content: str) -> str:
    """Elimina ! innecesarios"""
    # conversation.lastMessageAt! -> conversation.lastMessageAt
    pattern = r'conversation.lastMessageAt!'
    replacement = r'conversation.lastMessageAt'
    return re.sub(pattern, replacement, content)

def process_file(file_path: Path) -> tuple[bool, str]:
    """
    Procesa un archivo y aplica las correcciones
    Returns: (changed, message)
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        content = original_content
        changes = []    # Aplicar correcciones según el archivo
        if any(x in str(file_path) for x in ['home_page.dart', 'interest_selection_page.dart', 
                                              'discovery_page.dart', 'competitive_feed_page.dart',
                                              'feed_page.dart', 'premium_page.dart']):
            new_content = fix_with_opacity(content)
            if new_content != content:
                changes.append('withOpacity → withValues')
                content = new_content
        if 'main.dart' in str(file_path) or 'feed_bloc.dart' in str(file_path):
            new_content = fix_print_statements(content)
            if new_content != content:
                changes.append('Comentado print()')
                content = new_content
        if 'interest_selection_page.dart' in str(file_path):
            new_content = remove_unused_field(content, '_rotationAnimation')
            if new_content != content:
                changes.append('Removido _rotationAnimation')
                content = new_content
        if 'chat_list_page.dart' in str(file_path):
            new_content = fix_unnecessary_null_assertion(content)
            if new_content != content:
                changes.append('Removido ! innecesario')
                content = new_content
        # Guardar si hubo cambios
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, f"✅ {file_path.name}: {', '.join(changes)}"
        return False, f"⏭️  {file_path.name}: Sin cambios"
    except Exception as e:
        return False, f"❌ {file_path.name}: Error - {str(e)}"

def main():
    """Función principal"""
    print("🔧 Iniciando corrección de warnings de Flutter...\n")

    # Archivos a procesar
    files_to_fix = [
        'lib/main.dart',
        'lib/features/home/presentation/pages/home_page.dart',
        'lib/features/auth/presentation/pages/interest_selection_page.dart',
        'lib/features/discovery/presentation/pages/discovery_page.dart',
        'lib/features/feed/presentation/pages/competitive_feed_page.dart',
        'lib/features/feed/presentation/pages/feed_page.dart',
        'lib/features/feed/presentation/bloc/feed_bloc.dart',
        'lib/features/premium/presentation/pages/premium_page.dart',
        'lib/features/chat/presentation/pages/chat_list_page.dart',
    ]

    # Verificar que estamos en el directorio correcto
    if not os.path.exists('lib'):
        print("❌ Error: No se encontró el directorio 'lib'")
        print("   Asegúrate de ejecutar el script desde la raíz del proyecto Flutter")
        return

    results = []
    changed_count = 0
    for file_path_str in files_to_fix:
        file_path = Path(file_path_str)
        if not file_path.exists():
            results.append(f"⚠️  {file_path.name}: Archivo no encontrado")
            continue
        changed, message = process_file(file_path)
        results.append(message)
        if changed:
            changed_count += 1

    # Mostrar resultados
    print("\n".join(results))
    print(f"\n{'='*60}")
    print(f"📊 Resumen: {changed_count} archivos modificados")
    print(f"{'='*60}\n")

    if changed_count > 0:
        print("🎯 Pasos siguientes:")
        print("   1. Revisa los cambios con: git diff")
        print("   2. Ejecuta: flutter analyze")
        print("   3. Prueba la app: flutter run")
    else:
        print("✨ No se encontraron cambios necesarios")

if __name__ == '__main__':
    main()
