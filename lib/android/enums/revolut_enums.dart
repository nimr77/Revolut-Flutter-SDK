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
  none('NONE'),
  small('SMALL'),
  medium('MEDIUM'),
  large('LARGE');

  final String value;
  const ButtonRadius(this.value);
}

/// Button size options
enum ButtonSize {
  extraSmall('EXTRA_SMALL'),
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

/// Country code options
enum RevolutCountryCode {
  gb('GB'),
  us('US');

  final String value;
  const RevolutCountryCode(this.value);
}

/// Currency options for promotional banners
enum RevolutCurrency {
  gbp('GBP'),
  eur('EUR'),
  usd('USD');

  final String value;
  const RevolutCurrency(this.value);
}

/// Environment enum for SDK initialization
enum RevolutEnvironment {
  sandbox('SANDBOX'),
  main('MAIN');

  final String value;
  const RevolutEnvironment(this.value);
}
