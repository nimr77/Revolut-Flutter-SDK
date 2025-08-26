/// Box text options for button customization
enum BoxText {
  none('NONE'),
  getCashbackValue('GET_CASHBACK_VALUE'),
  getCashbackPercentage('GET_CASHBACK_PERCENTAGE');

  final String value;
  const BoxText(this.value);
}

/// Button radius options
enum ButtonRadius {
  small('SMALL'),
  medium('MEDIUM'),
  large('LARGE');

  final String value;
  const ButtonRadius(this.value);
}

/// Button size options
enum ButtonSize {
  small('SMALL'),
  medium('MEDIUM'),
  large('LARGE');

  final String value;
  const ButtonSize(this.value);
}

/// Button variant options
enum ButtonVariant {
  light('LIGHT'),
  dark('DARK');

  final String value;
  const ButtonVariant(this.value);
}

/// Environment enum for SDK initialization
enum RevolutEnvironment {
  main('MAIN'),
  sandbox('SANDBOX');

  final String value;
  const RevolutEnvironment(this.value);
}
