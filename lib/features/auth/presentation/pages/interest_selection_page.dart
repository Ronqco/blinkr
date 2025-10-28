import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/interest_categories.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class InterestSelectionPage extends StatefulWidget {
  const InterestSelectionPage({super.key});

  @override
  State<InterestSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<InterestSelectionPage> {
  final Set<String> _selectedInterests = {};
  bool _showNSFW = false;

  void _toggleInterest(String categoryId) {
    setState(() {
      if (_selectedInterests.contains(categoryId)) {
        _selectedInterests.remove(categoryId);
      } else {
        _selectedInterests.add(categoryId);
      }
    });
  }

  void _handleContinue() {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un interés'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthUpdateInterests(_selectedInterests.toList()),
        );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final sfwCategories = InterestCategories.sfw;
    final nsfwCategories = InterestCategories.nsfw;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus intereses'),
        actions: [
          TextButton(
            onPressed: _selectedInterests.isEmpty ? null : _handleContinue,
            child: const Text('Continuar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Elige los temas que te interesan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona al menos 3 para personalizar tu experiencia',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 24),

          // SFW Categories
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sfwCategories.map((category) {
              final isSelected = _selectedInterests.contains(category.id);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 4),
                    Text(category.name),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _toggleInterest(category.id),
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // NSFW Toggle
          Card(
            color: const Color(0xFFE67E22).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE67E22)),
                      const SizedBox(width: 8),
                      Text(
                        'Contenido para adultos (18+)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Blinkr permite contenido adulto con advertencias. Solo para mayores de 18 años.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Mostrar categorías NSFW'),
                    value: _showNSFW,
                    onChanged: (value) {
                      setState(() {
                        _showNSFW = value;
                        if (!value) {
                          // Remove NSFW interests if toggled off
                          _selectedInterests.removeWhere(
                            (id) => nsfwCategories.any((c) => c.id == id),
                          );
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          // NSFW Categories
          if (_showNSFW) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nsfwCategories.map((category) {
                final isSelected = _selectedInterests.contains(category.id);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 4),
                      Text(category.name),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => _toggleInterest(category.id),
                  selectedColor: const Color(0xFFE67E22).withOpacity(0.2),
                  backgroundColor: const Color(0xFFE67E22).withOpacity(0.05),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Selected count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intereses seleccionados',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_selectedInterests.length}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _selectedInterests.isEmpty ? null : _handleContinue,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
