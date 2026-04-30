import 'package:flutter/services.dart';

enum InputDevice {
  keyboard,
  mouse,
  gamepad,
  touch,
  unknown
}

enum MouseButton {
  left(0),
  right(1),
  middle(2),
  move(3),
  hover(4),
  unknown(-1);

  final int id;
  const MouseButton(this.id);
}

class PhysicalInput {
  final InputDevice device;
  final int keyId; 
  // For keyboard: keyId is logicalKey.keyId.
  // For mouse: 0=Left, 1=Right, 2=Middle.
  // For gamepad: specific button ids.
  
  const PhysicalInput({required this.device, required this.keyId});
  
  // Helper for keyboard keys
  factory PhysicalInput.keyboard(LogicalKeyboardKey key) {
    return PhysicalInput(device: InputDevice.keyboard, keyId: key.keyId);
  }
  // Helper for mouse buttons
  factory PhysicalInput.mouse(MouseButton button) {
    return PhysicalInput(device: InputDevice.mouse, keyId: button.id);
  }
  // Helper for touch
  factory PhysicalInput.touch(int index) {
    return PhysicalInput(device: InputDevice.touch, keyId: index);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalInput &&
          runtimeType == other.runtimeType &&
          device == other.device &&
          keyId == other.keyId;

  @override
  int get hashCode => device.hashCode ^ keyId.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'device': device.name,
      'keyId': keyId,
    };
  }

  factory PhysicalInput.fromJson(Map<String, dynamic> json) {
    return PhysicalInput(
      device: InputDevice.values.firstWhere(
        (e) => e.name == json['device'], 
        orElse: () => InputDevice.unknown
      ),
      keyId: json['keyId'],
    );
  }
}
