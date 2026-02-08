// import 'package:flutter/material.dart';

// void showAnimatedToast(BuildContext context, String message) {
//   final overlay = Navigator.of(context, rootNavigator: true).overlay;
//   if (overlay == null) return;

//   late OverlayEntry overlayEntry;

//   overlayEntry = OverlayEntry(
//     builder: (context) => AnimatedToast(
//       message: message,
//       onDismissed: () => overlayEntry.remove(),
//     ),
//   );

//   overlay.insert(overlayEntry);
// }

// class AnimatedToast extends StatefulWidget {
//   final String message;
//   final VoidCallback onDismissed;

//   const AnimatedToast({
//     super.key,
//     required this.message,
//     required this.onDismissed,
//   });

//   @override
//   State<AnimatedToast> createState() => _AnimatedToastState();
// }

// class _AnimatedToastState extends State<AnimatedToast>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _offsetAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(0, 1), // Começa abaixo da tela
//       end: const Offset(0, -0.2), // Sobe até um pouco acima do fundo
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack, // Efeito "mola" do iOS
//     ));

//     _controller.forward();

//     // Auto-dismiss após 3 segundos
//     Future.delayed(const Duration(seconds: 3), () => _reverseAndDismiss());
//   }

//   void _reverseAndDismiss() async {
//     if (mounted) {
//       await _controller.reverse();
//       widget.onDismissed();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Pegamos a altura da bottom bar para posicionar acima dela
//     final bottomPadding = kBottomNavigationBarHeight;

//     return Positioned(
//       bottom: bottomPadding,
//       left: 10,
//       right: 10,
//       child: SlideTransition(
//         position: _offsetAnimation,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF333333).withValues(alpha: 0.95),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     widget.message,
//                     style: const TextStyle(color: Colors.white, fontSize: 15),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // Importante para a física de mola

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
  double _dragOffset = 0.0;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 600), // Duração base
    );

    // Definindo a física da mola do iOS (Spring)
    // damping: 0.7 (suavidade), stiffness: 120 (rigidez)
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 120.0,
      damping: 12.0,
    );

    final simulation = SpringSimulation(spring, 0, 1, 0);
    _controller.animateWith(simulation);

    _startTimer();
  }

  void _startTimer() {
    _dismissTimer = Timer(const Duration(seconds: 3), _reverseAndDismiss);
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      _dismissTimer?.cancel();
      // Na saída, o iOS costuma ser um pouco mais rápido e linear
      await _controller.animateTo(0, curve: Curves.easeInQuad, duration: const Duration(milliseconds: 300));
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
      left: 10,
      right: 10,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculamos o slide baseado no valor da mola (0 a 1)
          // Quando 0, está 150px abaixo. Quando 1, está na posição final (0).
          final double slideTranslation = (1 - _controller.value) * 150;
          
          return Transform.translate(
            offset: Offset(0, slideTranslation + _dragOffset),
            child: Opacity(
              opacity: _controller.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragStart: (_) => _dismissTimer?.cancel(),
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragOffset += details.delta.dy;
              if (_dragOffset < 0) _dragOffset = _dragOffset * 0.2; // Resistência ao puxar para cima
            });
          },
          onVerticalDragEnd: (details) {
            if (_dragOffset > 50 || details.primaryVelocity! > 200) {
              _reverseAndDismiss();
            } else {
              setState(() => _dragOffset = 0);
              _startTimer();
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withOpacity(0.95), // Cor exata do Dark Mode iOS
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                        letterSpacing: -0.3, // Kerning do iOS
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
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