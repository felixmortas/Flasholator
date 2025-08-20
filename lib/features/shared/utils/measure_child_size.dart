import 'package:flutter/material.dart';

// Petit widget pour mesurer la taille d'un enfant et appeler onChange(size).
class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;
  const MeasureSize({required this.child, required this.onChange, Key? key}) : super(key: key);

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _oldSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void didUpdateWidget(covariant MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(Duration _) {
    if (!mounted) return;
    final contextSize = context.size;
    if (contextSize == null) return;
    if (_oldSize == contextSize) return;
    _oldSize = contextSize;
    widget.onChange(contextSize);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
        return true;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}
