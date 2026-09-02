import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BouncingWrapper extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scaleDown;

  const BouncingWrapper({
    super.key,
    this.onTap,
    required this.child,
    this.scaleDown = 0.05,
  });

  @override
  State<BouncingWrapper> createState() => _BouncingWrapperState();
}

class _BouncingWrapperState extends State<BouncingWrapper> {
  bool _isPressed = false;
  Offset _dragOffset = Offset.zero;

  void _onPressDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
    });
  }

  void _onPressRelease() {
    setState(() {
      _isPressed = false;
      _dragOffset = Offset.zero;
    });
  }

  void _handleTap() {
    _onPressRelease();
    if (widget.onTap != null) {
      HapticFeedback.mediumImpact();
      widget.onTap!();
    }
  }

  void _onPanDown(DragDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      // Limit maximum stretch distance
      if (_dragOffset.distance > 100) {
        _dragOffset = Offset.fromDirection(_dragOffset.direction, 100);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPressed = false;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanCancel() {
    setState(() {
      _isPressed = false;
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate squash and stretch factors based on drag distance
    final double distance = _dragOffset.distance;
    final double stretch = 1.0 + (distance / 400); // Stretch along drag axis
    final double squash = 1.0 - (distance / 400); // Squash perpendicular axis

    // Handle the case where distance is 0 to avoid NaN direction
    final double angle = distance > 0 ? _dragOffset.direction : 0;

    Matrix4 transform = Matrix4.identity();

    // 1. Base press scale
    final baseScale = _isPressed ? (1.0 - widget.scaleDown) : 1.0;
    transform.scaleByDouble(baseScale, baseScale, 1.0, 1.0);

    // 2. Translate slightly with resistance in the direction of the drag
    transform.translateByDouble(
      _dragOffset.dx * 0.4,
      _dragOffset.dy * 0.4,
      0.0,
      1.0,
    );

    // 3. Rotate to match drag angle
    transform.rotateZ(angle);

    // 4. Apply stretch and squash relative to the drag angle
    transform.scaleByDouble(stretch, squash, 1.0, 1.0);

    // 5. Rotate back
    transform.rotateZ(-angle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _onPressDown(),
      onTapUp: (_) => _onPressRelease(),
      onTapCancel: _onPressRelease,
      onTap: _handleTap,
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: AnimatedContainer(
        duration: _isPressed
            ? const Duration(milliseconds: 100)
            : const Duration(milliseconds: 800),
        curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
        transform: transform,
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
