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
  late Animation<Offset> _entryAnimation;
  
  double _dragOffset = 0.0; // Controla o deslocamento do dedo
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _entryAnimation = Tween<Offset>(
      begin: const Offset(0, 2), // Começa bem abaixo
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Curva de mola nativa do iOS
    ));

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _dismissTimer = Timer(const Duration(seconds: 3), _reverseAndDismiss);
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      _dismissTimer?.cancel();
      await _controller.reverse();
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
    // Posicionamento acima da BottomBar
    final bottomPadding = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 10;

    return Positioned(
      bottom: bottomPadding,
      left: 10,
      right: 10,
      child: GestureDetector(
        onVerticalDragStart: (_) => _dismissTimer?.cancel(),
        onVerticalDragUpdate: (details) {
          setState(() {
            // Apenas permite arrastar para baixo (valores positivos)
            _dragOffset += details.delta.dy;
            if (_dragOffset < 0) _dragOffset = 0; 
          });
        },
        onVerticalDragEnd: (details) {
          // Se arrastou mais de 40px ou soltou com velocidade para baixo
          if (_dragOffset > 40 || details.primaryVelocity! > 100) {
            _reverseAndDismiss();
          } else {
            // Volta para a posição original suavemente
            setState(() => _dragOffset = 0);
            _startTimer();
          }
        },
        child: AnimatedContainer(
          duration: _dragOffset == 0 ? const Duration(milliseconds: 200) : Duration.zero,
          curve: Curves.easeInOutBack,
          transform: Matrix4.translationValues(0, _dragOffset, 0), // O segredo da suavidade
          child: SlideTransition(
            position: _entryAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
      ),
    );
  }
}