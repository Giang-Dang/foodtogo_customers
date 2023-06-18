import 'package:flutter/material.dart';

class RatingButton extends StatefulWidget {
  const RatingButton({
    super.key,
    required this.onButtonPressed,
  });

  final Function() onButtonPressed;

  @override
  State<RatingButton> createState() => _RatingButtonState();
}

class _RatingButtonState extends State<RatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _colorAnimation = ColorTween(
      begin: Colors.amber.shade400,
      end: Colors.amber.shade700,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: IconButton(
            icon: Icon(
              Icons.star,
              color: _colorAnimation.value,
              size: 26,
            ),
            onPressed: widget.onButtonPressed,
          ),
        );
        // Handle button press
      },
    );
  }
}
