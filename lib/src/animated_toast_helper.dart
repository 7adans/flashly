import 'package:flutter/material.dart';

void showAnimatedSnackBar(BuildContext context, Widget child) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: kBottomNavigationBarHeight,
        child: _SlidingSnackBar(
          onClose: () => entry.remove(),
          child: child,
        ),
      );
    },
  );

  overlay.insert(entry);
}

class _SlidingSnackBar extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  const _SlidingSnackBar({required this.child, required this.onClose});

  @override
  State<_SlidingSnackBar> createState() => _SlidingSnackBarState();
}

class _SlidingSnackBarState extends State<_SlidingSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () async {
      await _controller.reverse();
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Material(
        color: Colors.grey[900],
        child: widget.child,
      ),
    );
  }
}
