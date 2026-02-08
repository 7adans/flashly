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
  late Animation<double> _animation;
  double _dragOffset = 0.0;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    
    // Tempo total curto para ser responsivo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), 
    );

    // Esta curva (cubic-bezier) é o segredo do iOS. 
    // Ela começa muito rápido e desacelera suavemente no final, sem balançar (bounce) demais.
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.2, 0.9, 0.4, 1.05), // Quase um spring, mas sem o "atraso"
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
      // Saída rápida e linear para baixo
      await _controller.animateTo(0, 
        curve: Curves.easeInCubic, 
        duration: const Duration(milliseconds: 250)
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
      left: 10,
      right: 10,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Começa apenas 60px abaixo para ser ultra rápido
          final double slideTranslation = (1 - _animation.value) * 60;
          
          return Transform.translate(
            offset: Offset(0, slideTranslation + _dragOffset),
            child: Opacity(
              // Fade in rápido junto com o slide
              opacity: _controller.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _dismissTimer?.cancel();
            setState(() {
              _dragOffset += details.delta.dy;
              if (_dragOffset < 0) _dragOffset = 0; // Trava o arraste para cima
            });
          },
          onVerticalDragEnd: (details) {
            if (_dragOffset > 40 || details.primaryVelocity! > 100) {
              _reverseAndDismiss();
            } else {
              // Volta com "mola" manual via AnimatedContainer ou setState direto
              setState(() => _dragOffset = 0);
              _startTimer();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, 0, 0), // Auxilia na suavidade do render
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E), // iOS Dark Grey
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}