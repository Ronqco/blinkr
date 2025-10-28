import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  Map<String, dynamic>? _userData;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = widget.userId ?? supabase.auth.currentUser?.id;
      
      if (userId == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _userData = response;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.userId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'Mi Perfil' : 'Perfil'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 60,
                        child: Text(
                          (_userData!['display_name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData!['display_name'] ?? 'Usuario',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '@${_userData!['username'] ?? 'username'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      if (_userData!['bio'] != null) ...[
                        const SizedBox(height: 16),
                        Text(_userData!['bio']),
                      ],
                      const SizedBox(height: 24),
                      if (isOwnProfile) ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Función de editar perfil próximamente'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar perfil'),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Iniciar chat')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Mensaje'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}