import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blinkr Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 80,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 24),
          Text(
            'Blinkr Premium',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${AppConfig.premiumPriceUSD}/mes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          _buildFeature(
            context,
            Icons.chat_bubble,
            'Mensajes ilimitados',
            'Envía todos los mensajes que quieras sin límites',
          ),
          _buildFeature(
            context,
            Icons.block,
            'Sin anuncios',
            'Disfruta de Blinkr sin interrupciones',
          ),
          _buildFeature(
            context,
            Icons.verified,
            'Insignia Premium',
            'Destaca con una insignia especial en tu perfil',
          ),
          _buildFeature(
            context,
            Icons.visibility,
            'Más visibilidad',
            'Aparece más en los resultados de búsqueda',
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Handle premium subscription
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suscripción Premium - Próximamente'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Suscribirse ahora'),
          ),
          const SizedBox(height: 16),
          Text(
            'Cancela cuando quieras. Se renueva automáticamente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
