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
import 'package:flutter/physics.dart';

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
    // Reduzimos o tempo total para a animação não parecer "arrastada"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450), 
    );

    // AJUSTE DA MOLA: 
    // Stiffness maior (180) = resposta mais rápida.
    // Damping (15) = para de balançar mais rápido, sem o delay que você notou.
    final spring = SpringDescription(
      mass: 0.8, // Menor massa para ser mais ágil
      stiffness: 180.0, 
      damping: 15.0,
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
      // Saída mais direta, estilo iOS
      await _controller.animateTo(0, curve: Curves.easeInQuart, duration: const Duration(milliseconds: 250));
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
          // O slide agora é mais curto (100px) para não demorar a chegar no destino
          final double slideTranslation = (1 - _controller.value) * 100;
          
          return Transform.translate(
            offset: Offset(0, slideTranslation + _dragOffset),
            child: child,
          );
        },
        child: GestureDetector(
          onVerticalDragStart: (_) => _dismissTimer?.cancel(),
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragOffset += details.delta.dy;
              if (_dragOffset < 0) _dragOffset = _dragOffset * 0.2; 
            });
          },
          onVerticalDragEnd: (details) {
            if (_dragOffset > 40 || details.primaryVelocity! > 150) {
              _reverseAndDismiss();
            } else {
              // Volta imediata se não atingir o limite de descarte
              setState(() => _dragOffset = 0);
              _startTimer();
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withOpacity(0.98),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
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
                        letterSpacing: -0.4,
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