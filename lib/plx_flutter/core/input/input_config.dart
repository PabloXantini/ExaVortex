import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'physical_input.dart';
import 'input_manager.dart';

class InputConfig {
  static const String _fileName = 'input_config.json';

  static Future<File> _getConfigFile() async {
    final directory = await getApplicationSupportDirectory(); // better for hidden configs
    return File('${directory.path}/$_fileName');
  }

  static Future<void> saveConfig(InputManager manager) async {
    try {
      final file = await _getConfigFile();
      final bindings = manager.getBindings();
      
      final Map<String, dynamic> jsonMap = {};
      bindings.forEach((input, actions) {
        final inputKey = jsonEncode(input.toJson());
        jsonMap[inputKey] = actions;
      });

      await file.writeAsString(jsonEncode(jsonMap));
      debugPrint('Input config saved to ${file.path}');
    } catch (e) {
      debugPrint('Error saving input config: $e');
    }
  }

  static Future<bool> loadConfig(InputManager manager) async {
    try {
      final file = await _getConfigFile();
      if (!await file.exists()) {
        debugPrint('Config file does not exist, using defaults.');
        return false;
      }

      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      manager.clearBindings();
      
      jsonMap.forEach((inputKey, actionsList) {
        final Map<String, dynamic> inputJson = jsonDecode(inputKey);
        final input = PhysicalInput.fromJson(inputJson);
        
        final List<String> actions = List<String>.from(actionsList);
        for (final action in actions) {
          manager.bindInput(input, action);
        }
      });
      
      debugPrint('Input config loaded from ${file.path}');
      return true;
    } catch (e) {
      debugPrint('Error loading input config: $e');
      return false;
    }
  }
}
