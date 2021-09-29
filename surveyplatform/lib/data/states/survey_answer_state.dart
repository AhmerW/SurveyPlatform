import 'package:flutter/cupertino.dart';
import 'package:surveyplatform/models/survey.dart';

class SurveyAnswerState extends ChangeNotifier {
  int survey_id = Survey.invalidID;
  Map<int, QuestionAnswer> _answers = {};

  void fromSurvey(Survey survey) {
    clear();
    survey_id = survey.surveyid;
  }

  void asJson() {}

  void clear() {
    _answers.clear();
    survey_id = Survey.invalidID;
  }

  void addAnswer(int id, QuestionAnswer answer) {
    _answers[id] = answer;
  }

  QuestionAnswer? getAnswer(int id) => _answers[id] ?? null;
}

class QuestionAnswer {
  final int question_id;
  final bool mandatory;

  String _value = "";

  String get value => _value;
  void setValue(String value) => _value = value;

  QuestionAnswer(this.question_id, {required this.mandatory});
  factory QuestionAnswer.fromQuestion(Question question) {
    return QuestionAnswer(
      question.questionID ?? 0,
      mandatory: question.mandatory,
    );
  }
}
