int parse(dynamic value, {int defaultValue: 0}) {
  int v;
  if (value is String) {
    v = int.tryParse(value) ?? defaultValue;
  } else {
    v = defaultValue;
  }
  return v;
}

double parseDouble(dynamic value, {double defaultValue: 0.0}) {
  return parse(value, defaultValue: defaultValue.toInt()).toDouble();
}

bool validateInteger(String value) {
  int? val = int.tryParse(value);
  return val != null;
}
