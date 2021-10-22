import 'package:flutter/cupertino.dart';
import 'package:surveyplatform/models/survey.dart';

class SurveyAnswerState extends ChangeNotifier {
  int survey_id = Survey.invalidID;
  Map<int, List<QuestionAnswer>> _answers = {}; // question_id : answer

  void fromSurvey(Survey survey) {
    clear();
    survey_id = survey.surveyID;
  }

  Map<String, dynamic> toJson(int survey_id) {
    if (!_answers.containsKey(survey_id)) return {};
    return Map.fromIterable(
      _answers[survey_id]!,
      key: (qa) => qa.question_id,
      value: (qa) => qa.toJson(),
    );
  }

  void clear() {
    _answers.clear();
    survey_id = Survey.invalidID;
  }

  void addAnswer(int survey_id, QuestionAnswer answer) {
    if (!_answers.containsKey(survey_id)) {
      _answers[survey_id] = [answer];
    } else {
      _answers[survey_id]!.removeWhere(
        (a) => a.question_id == answer.question_id,
      );
      _answers[survey_id]!.add(answer);
    }
  }

  void answer(int survey_id, String value, {required Question question}) {
    addAnswer(
      survey_id,
      QuestionAnswer(question.questionID),
    );
  }

  List<QuestionAnswer> getAnswers(int survey_id) =>
      _answers[survey_id] ?? <QuestionAnswer>[];

  QuestionAnswer? getAnswer(int survey_id, int question_id) {
    try {
      return getAnswers(survey_id)
          .singleWhere((answer) => answer.question_id == question_id);
    } catch (error) {
      return null;
    }
  }

  bool questionIsAnswered(int survey_id, int question_id,
      {bool isMandatory: false}) {
    QuestionAnswer? qa = getAnswer(survey_id, question_id);
    if (qa == null) return false;
    return qa.isAnswered(isMandatory: isMandatory);
  }

  bool isAnswered(int survey_id, List<Question> questions) {
    return questions
        .map((q) => questionIsAnswered(
              survey_id,
              q.questionID,
              isMandatory: q.mandatory,
            ))
        .every(
          (element) => element,
        );
  }

  void fromQuestions(int survey_id, List<Question> questions) {
    _answers[survey_id] =
        questions.map((q) => QuestionAnswer.fromQuestion(q)).toList();
  }
}

class QuestionAnswer {
  final int question_id;

  String _value = "";

  String get value => _value;
  void setValue(String value) => _value = value;
  bool isAnswered({isMandatory: false}) =>
      !isMandatory ? true : _value.isNotEmpty;

  Map<String, dynamic> toJson() => {"value": value};

  QuestionAnswer(this.question_id);
  factory QuestionAnswer.fromQuestion(Question question) {
    return QuestionAnswer(
      question.questionID,
    );
  }
}
