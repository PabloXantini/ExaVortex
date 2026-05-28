import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] used by [GameScene] to signal that its UI layer needs
/// to be rebuilt. Call [notify] from the scene instead of [notifyListeners].
class PlxUINotifier extends ChangeNotifier {
  /// Signals all listeners that the UI should rebuild.
  void notify() => notifyListeners();
}
