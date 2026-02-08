import 'dart:async';
import 'package:flutter/material.dart';

void showAnimatedToast(BuildContext context, String message) {
  final overlay = Navigator.of(context, rootNavigator: true).overlay;
  if (overlay == null) return;

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedToast(
      message: message,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class AnimatedToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const AnimatedToast({super.key, required this.message, required this.onDismissed});

  @override
  State<AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<AnimatedToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  double _dragOffset = 0.0;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Tempo para a mola respirar
    );

    // Mola do iOS: sobe rápido, passa um pouco (1.07) e volta para o 1.0
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.175, 0.885, 0.32, 1.07), 
    );

    // Fade de saída muito mais lento e natural
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1, curve: Curves.linear),
    );

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _dismissTimer = Timer(const Duration(seconds: 3), _reverseAndDismiss);
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      _dismissTimer?.cancel();
      // Saída: desaceleração suave ao cair (Curves.easeInBack tira o fade abrupto)
      await _controller.animateTo(0, 
        curve: Curves.easeInOutCubic, 
        duration: const Duration(milliseconds: 450) // Saída mais lenta como pedido
      );
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 10;

    return Positioned(
      bottom: bottomPadding,
      left: 12,
      right: 12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Aumentamos de 80 para 160 apenas para garantir que no valor 0 
          // ele esteja bem abaixo da linha da tela.
          // O valor 1 continua sendo 0 (posição de descanso).
          final double slideTranslation = (1 - _slideAnimation.value) * 160;
          
          return Transform.translate(
            offset: Offset(0, slideTranslation + _dragOffset),
            child: Opacity(
              // Aplicando a opacidade que tínhamos configurado mas não estava no widget
              opacity: _opacityAnimation.value, 
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _dismissTimer?.cancel();
            setState(() {
              _dragOffset += details.delta.dy;
              if (_dragOffset < 0) _dragOffset = 0; 
            });
          },
          onVerticalDragEnd: (details) {
            if (_dragOffset > 40 || details.primaryVelocity! > 100) {
              _reverseAndDismiss();
            } else {
              // Volta suave se o usuário soltar
              setState(() => _dragOffset = 0);
              _startTimer();
            }
          },
          // Container com design fiel ao iOS 17/18
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withOpacity(0.96),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}