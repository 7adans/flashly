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

  const AnimatedToast({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Começa abaixo da tela
      end: const Offset(0, -0.2), // Sobe até um pouco acima do fundo
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Efeito "mola" do iOS
    ));

    _controller.forward();

    // Auto-dismiss após 3 segundos
    Future.delayed(const Duration(seconds: 3), () => _reverseAndDismiss());
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos a altura da bottom bar para posicionar acima dela
    final bottomPadding = kBottomNavigationBarHeight;

    return Positioned(
      bottom: bottomPadding,
      left: 10,
      right: 10,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF333333).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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