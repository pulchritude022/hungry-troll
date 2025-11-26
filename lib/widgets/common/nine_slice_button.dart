import 'package:flutter/material.dart';

enum ButtonType { blue, red }

class NineSliceButton extends StatefulWidget {
  final ButtonType type;
  final Widget? child;
  final VoidCallback? onTap;
  final bool disabled;
  final double width;
  final double height;

  const NineSliceButton({
    super.key,
    required this.type,
    this.child,
    this.onTap,
    this.disabled = false,
    this.width = 120,
    this.height = 60,
  });

  @override
  State<NineSliceButton> createState() => _NineSliceButtonState();
}

class _NineSliceButtonState extends State<NineSliceButton> {
  bool _isPressed = false;

  String get _assetPath {
    if (widget.disabled) {
      return 'assets/images/ui/buttons/button_disable_9slides.png';
    }

    String colorPart;
    switch (widget.type) {
      case ButtonType.blue:
        colorPart = 'blue';
        break;
      case ButtonType.red:
        colorPart = 'red';
        break;
    }

    if (_isPressed) {
      return 'assets/images/ui/buttons/button_${colorPart}_9slides_pressed.png';
    } else {
      return 'assets/images/ui/buttons/button_${colorPart}_9slides.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.disabled) {
          setState(() {
            _isPressed = true;
          });
        }
      },
      onTapUp: (_) {
        if (!widget.disabled) {
          setState(() {
            _isPressed = false;
          });
          widget.onTap?.call();
        }
      },
      onTapCancel: () {
        if (!widget.disabled) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              _assetPath,
              scale: 2.0,
              centerSlice: const Rect.fromLTWH(64, 64, 64, 64),
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

