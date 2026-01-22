/// Theme Aware Builder Widget
///
/// A widget that rebuilds when the system theme changes.
/// This ensures the app responds to system theme changes in real-time.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A widget that rebuilds when the system brightness changes
class ThemeAwareBuilder extends StatefulWidget {
  /// Child widget builder that receives current brightness
  final Widget Function(BuildContext context, Brightness brightness) builder;

  const ThemeAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<ThemeAwareBuilder> createState() => _ThemeAwareBuilderState();
}

class _ThemeAwareBuilderState extends State<ThemeAwareBuilder>
    with WidgetsBindingObserver {
  Brightness _brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final newBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    if (_brightness != newBrightness) {
      setState(() {
        _brightness = newBrightness;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness);
  }
}
