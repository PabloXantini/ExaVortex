import 'physical_input.dart';

enum InputEventType {
  pressed,
  released,
  held,
  axisChange
}

class InputEvent {
  final PhysicalInput input;
  final InputEventType type;
  final double value;

  const InputEvent({
    required this.input,
    required this.type,
    this.value = 0.0
  });
}
