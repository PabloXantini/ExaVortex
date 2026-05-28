import 'package:exa_vortex/plx/core/utils/device.dart';
import 'package:exa_vortex/plx/core/utils/platform_hints.dart';
import 'package:flutter/services.dart';

/// Enum helper for screen orientation.
/// Internally uses [DeviceOrientation] for setting preferred orientations.
/// Provides more flexibility than DeviceOrientation.
enum ScreenOrientation {
  portraitUp,
  portraitDown,
  landscapeLeft,
  landscapeRight,
  portrait,
  landscape,
  any
}

class MobileHints extends PlatformHints{
  @override
  Future<void> toggleFullScreen(bool fullScreen) async {
    if(!Device.isMobile) return;
    if(fullScreen){
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }else{
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
  Future<void> setOrientation(ScreenOrientation orientation) async {
    if(!Device.isMobile) return;
    List<DeviceOrientation> orientations = [];
    switch (orientation) {
      case ScreenOrientation.portraitUp:
        orientations = [DeviceOrientation.portraitUp];
        break;
      case ScreenOrientation.portraitDown:
        orientations = [DeviceOrientation.portraitDown];
        break;
      case ScreenOrientation.landscapeLeft:
        orientations = [DeviceOrientation.landscapeLeft];
        break;
      case ScreenOrientation.landscapeRight:
        orientations = [DeviceOrientation.landscapeRight];
        break;
      case ScreenOrientation.portrait:
        orientations = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
        break;
      case ScreenOrientation.landscape:
        orientations = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
        break;
      case ScreenOrientation.any:
        orientations = DeviceOrientation.values;
        break;
    }
    await SystemChrome.setPreferredOrientations(orientations);
  }
}