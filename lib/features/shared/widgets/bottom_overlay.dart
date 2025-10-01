import 'package:flutter/material.dart';
import 'package:flasholator/style/bottom_overlay_styles.dart';

import 'package:flasholator/config/constants.dart';

class BottomBlock extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool showDragHandle;
  final Color borderColor;

  const BottomBlock({
    super.key,
    required this.children,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = 25 * GOLDEN_NUMBER,
    this.showDragHandle = true,
    this.borderColor = BottomBlockStyles.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          key: const Key('BottomBlock'),
          width: double.infinity,
          decoration: BottomBlockStyles.outerDecoration(
            color: borderColor,
            radius: borderRadius,
          ),
          padding: BottomBlockStyles.borderPadding,
          child: Container(
            decoration: BottomBlockStyles.innerDecoration(
              backgroundColor: backgroundColor,
              radius: borderRadius,
            ),
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
              ],
            ),
          ),
        ),
        // Poignée centrale en haut
        if (showDragHandle) TopHandle(backgroundColor: borderColor),
        
        // Coins protecteurs
        CornerProtection(isLeft: true, color: borderColor),
        CornerProtection(isLeft: false, color: borderColor),
      ],
    );
  }
}