class InputAction {
  final String name;
  bool isTriggered = false;
  bool wasTriggeredThisFrame = false;
  bool wasReleasedThisFrame = false;
  double value = 0.0; // For axes, or 1.0 for pressed buttons

  InputAction(this.name);

  void update(bool pressed, double newValue) {
    wasTriggeredThisFrame = pressed && !isTriggered;
    wasReleasedThisFrame = !pressed && isTriggered;
    isTriggered = pressed;
    value = newValue;
  }
  
  void resetFrame() {
    wasTriggeredThisFrame = false;
    wasReleasedThisFrame = false;
  }
}
