import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/plx/core/utils/device.dart';
import 'package:exa_vortex/plx/core/utils/platform_hints.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

class DesktopHints extends PlatformHints{
  @override
  Future<void> init() async {
    if(!Device.isDesktop) return;
    try {
      await windowManager.ensureInitialized();
    } on MissingPluginException catch (e) {
      // Catch exception if the plugin is not properly built/registered
      PlxLogger.error("window_manager plugin is missing. Please rebuild the app. ($e)",system: 'PlatformHint(Desktop)');
    } catch (e) {
      PlxLogger.error("Error initializing window_manager. ($e)", system: "PlatformHint(Desktop)");
    }
  }

  @override
  Future<void> toggleFullScreen(bool fullScreen) async{
    if(!Device.isDesktop) return;
    try {
      await windowManager.setFullScreen(fullScreen);
    } catch (e) {
      PlxLogger.error("Error toggling full screen. ($e)", system: "PlatformHint(Desktop)");
    }
  }
}