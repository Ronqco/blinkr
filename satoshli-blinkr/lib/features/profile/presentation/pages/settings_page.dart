import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to edit profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.interests_outlined),
            title: const Text('Mis intereses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/interests'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Privacidad de ubicación'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to location settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Usuarios bloqueados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to blocked users
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Blinkr Premium'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
