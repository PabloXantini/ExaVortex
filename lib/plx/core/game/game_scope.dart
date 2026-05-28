import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:exa_vortex/plx/core/logger.dart';

class PlxGameScope extends StatefulWidget {
  final Widget child;
  final Future<bool> Function() onExitRequest;
  final void Function(AppLifecycleState) onLifecycleStateChange;

  const PlxGameScope({
    super.key,
    required this.child,
    required this.onExitRequest,
    required this.onLifecycleStateChange,
  });

  @override
  State<PlxGameScope> createState() => _PlxGameScopeState();
}

class _PlxGameScopeState extends State<PlxGameScope> with WidgetsBindingObserver {
  // Tracks whether a pop was approved to avoid re-entering the exit check
  bool _popApproved = false;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onLifecycleStateChange(state);
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    PlxLogger.message("System requested app exit...", system: "GameScope");
    final allowClose = await widget.onExitRequest();
    if (allowClose) {
      PlxLogger.message("App exit allowed", system: "GameScope");
      return AppExitResponse.exit;
    }
    PlxLogger.message("App exit denied", system: "GameScope");
    return AppExitResponse.cancel;
  }

  Future<void> _handlePopRequest(BuildContext context) async {
    if (_popApproved) return;
    PlxLogger.message("System requested pop (PopScope)...", system: "GameScope");
    final allowClose = await widget.onExitRequest();
    if (!allowClose) {
      PlxLogger.message("App pop denied", system: "GameScope");
      return;
    }
    // Mark approved and pop after the current frame to avoid rebuild conflict
    _popApproved = true;
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _popApproved) return;
        _handlePopRequest(context);
      },
      child: widget.child,
    );
  }
}
