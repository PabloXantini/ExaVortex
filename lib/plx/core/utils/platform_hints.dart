import 'package:exa_vortex/plx/core/utils/desktop_hints.dart';
import 'package:exa_vortex/plx/core/utils/mobile_hints.dart';

///General platform hints snippet facade for change in each platform
///Must support mobile and desktop 
class PlxPlatform {
  static MobileHints mobile = MobileHints();
  static DesktopHints desktop = DesktopHints();
  
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await desktop.init();
    await mobile.init();
  }
  
  static Future<void> toggleFullScreen(bool fullScreen) async {
    await desktop.toggleFullScreen(fullScreen);
    await mobile.toggleFullScreen(fullScreen);
  }
}

abstract class PlatformHints {
  Future<void> init() async {}
  Future<void> toggleFullScreen(bool fullScreen);
}