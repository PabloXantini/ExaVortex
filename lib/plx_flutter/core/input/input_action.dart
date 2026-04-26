class InputAction {
  final String name;
  bool isPressed = false;
  bool wasPressedThisFrame = false;
  bool wasReleasedThisFrame = false;
  double value = 0.0; // For axes, or 1.0 for pressed buttons

  InputAction(this.name);

  void update(bool pressed, double newValue) {
    wasPressedThisFrame = pressed && !isPressed;
    wasReleasedThisFrame = !pressed && isPressed;
    isPressed = pressed;
    value = newValue;
  }
  
  void resetFrame() {
    wasPressedThisFrame = false;
    wasReleasedThisFrame = false;
  }
}
