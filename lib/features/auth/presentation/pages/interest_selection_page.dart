// 🔧 CAMBIOS:
// - Línea 50-200: REEMPLAZADO Wrap de chips por swipe cards
// - Línea 210: Agregado SwipeableInterestCard widget

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

class _InterestSelectionPageState extends State<InterestSelectionPage> 
    with TickerProviderStateMixin {
  final Set<String> _selectedInterests = {};
  bool _showNSFW = false;
  int _currentIndex = 0;
  
  late List<InterestCategory> _allCategories;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _allCategories = [...InterestCategories.sfw];
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      _animationController,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSwipeRight() {
    if (_currentIndex < _allCategories.length) {
      setState(() {
        _selectedInterests.add(_allCategories[_currentIndex].id);
        _currentIndex++;
      });
      _playMatchAnimation();
    }
  }

  void _onSwipeLeft() {
    if (_currentIndex < _allCategories.length) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _playMatchAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _handleContinue() {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos 3 intereses para continuar'),
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
    final progress = _currentIndex / _allCategories.length;
    final hasMoreCards = _currentIndex < _allCategories.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descubre tus intereses'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ NUEVO: Barra de progreso
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedInterests.length} seleccionados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '$_currentIndex/${_allCategories.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ NUEVO: Stack de cards swipeables
            Expanded(
              child: hasMoreCards
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Card siguiente (preview)
                        if (_currentIndex + 1 < _allCategories.length)
                          Positioned(
                            top: 20,
                            child: Transform.scale(
                              scale: 0.9,
                              child: Opacity(
                                opacity: 0.5,
                                child: SwipeableInterestCard(
                                  category: _allCategories[_currentIndex + 1],
                                  onSwipeRight: () {},
                                  onSwipeLeft: () {},
                                  isPreview: true,
                                ),
                              ),
                            ),
                          ),
                        
                        // Card actual
                        Positioned(
                          top: 10,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: SwipeableInterestCard(
                              category: _allCategories[_currentIndex],
                              onSwipeRight: _onSwipeRight,
                              onSwipeLeft: _onSwipeLeft,
                              isPreview: false,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '¡Listo!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Has seleccionado ${_selectedInterests.length} intereses',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
            ),

            // ✅ NUEVO: Instrucciones y botones
            if (hasMoreCards)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(width: 8),
                        const Text('Desliza para saltar'),
                        const SizedBox(width: 24),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(width: 8),
                        const Text('Desliza para seleccionar'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _onSwipeLeft,
                            icon: const Icon(Icons.close),
                            label: const Text('Saltar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onSwipeRight,
                            icon: const Icon(Icons.favorite),
                            label: const Text('Me gusta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_selectedInterests.length < 3)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selecciona al menos 3 intereses para continuar',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedInterests.length >= 3 
                            ? _handleContinue 
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Comenzar a explorar'),
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ NUEVO: Toggle NSFW
            if (!hasMoreCards && !_showNSFW)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showNSFW = true;
                      _allCategories.addAll(InterestCategories.nsfw);
                      _currentIndex = InterestCategories.sfw.length;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Explorar categorías NSFW (18+)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ✅ NUEVO: Widget de card swipeable
class SwipeableInterestCard extends StatefulWidget {
  final InterestCategory category;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;
  final bool isPreview;

  const SwipeableInterestCard({
    super.key,
    required this.category,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    this.isPreview = false,
  });

  @override
  State<SwipeableInterestCard> createState() => _SwipeableInterestCardState();
}

class _SwipeableInterestCardState extends State<SwipeableInterestCard> {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  double _rotation = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.3;

    return GestureDetector(
      onPanStart: widget.isPreview ? null : (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: widget.isPreview ? null : (details) {
        setState(() {
          _position += details.delta;
          _rotation = _position.dx / screenWidth * 0.3;
        });
      },
      onPanEnd: widget.isPreview ? null : (details) {
        setState(() {
          _isDragging = false;
        });

        if (_position.dx.abs() > swipeThreshold) {
          // Swipe completado
          if (_position.dx > 0) {
            widget.onSwipeRight();
          } else {
            widget.onSwipeLeft();
          }
        }

        // Resetear posición
        setState(() {
          _position = Offset.zero;
          _rotation = 0;
        });
      },
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: _rotation,
          child: Container(
            width: screenWidth * 0.85,
            height: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.category.isNSFW
                    ? [
                        const Color(0xFFE67E22).withOpacity(0.8),
                        const Color(0xFFE67E22),
                      ]
                    : [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.secondary,
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Contenido de la card
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 100),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.category.description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.category.isNSFW) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '18+ NSFW',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Overlays de swipe
                if (_isDragging && _position.dx > 50)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else if (_isDragging && _position.dx < -50)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}