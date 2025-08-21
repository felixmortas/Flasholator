import 'package:flutter/material.dart';

import 'package:flasholator/config/constants.dart';

class BottomBlock extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool showDragHandle;

  const BottomBlock({
    super.key,
    required this.children,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = 25 * GOLDEN_NUMBER,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        key: const Key('BottomBlock'),
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) const _DragHandle(),
            ...children,
          ],
        ),
      
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('BottomBlockDragHandle'),
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
