import 'dart:io';
import 'package:flutter/foundation.dart';

class Device {
  static bool isMobile = Platform.isAndroid || Platform.isIOS;
  static bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  static bool isWeb = kIsWeb;
}