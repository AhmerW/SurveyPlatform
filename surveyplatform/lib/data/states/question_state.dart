import 'package:flutter/cupertino.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/widgets/surveys/widgets/base.dart';

class QuestionState extends ChangeNotifier {
  final String widget;
  final Map<String, dynamic> values;
  late int _position;
  String _text = "";
  bool _mandatory = true;

  String get text => _text;
  int get position => _position;
  bool get mandatory => _mandatory;

  QuestionState(
    int this._position, {
    required this.widget,
    this.values: const {},
  });

  Question get question => Question(
      questionID: 0,
      text: text,
      position: position,
      widget: widget,
      widget_values: values,
      mandatory: mandatory);

  void setMandatory(bool value) {
    print("mandatory: $value");
    _mandatory = value;
    notifyListeners();
  }

  void setPosition(int pos) {
    _position = pos;
    notifyListeners();
  }

  void setQuestionText(String text) {
    print("setting $text");
    _text = text;
    notifyListeners();
  }
}
