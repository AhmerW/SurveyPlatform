import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/services/answer_service.dart';

class SurveyAnswerState extends ChangeNotifier {
  Map<int, List<QuestionAnswer>> _answers = {}; // survey_id : answers

  // answered surveys
  Map<int, Map<int, bool>> _answered = {}; // uid: List[survey_id]
  List<int> _fetchedAnswered = []; // survey

  Future<bool> surveyIsAnswered(
    int uid,
    int survey_id, {
    required String token,
  }) async {
    if (_answered.containsKey(uid)) {
      if (_answered[uid]!.containsKey(survey_id)) {
        return _answered[uid]![survey_id]!;
      }
    } else {
      _answered[uid] = {};
    }

    bool answered = await locator<AnswerService>().isSurveyAnswered(
      survey_id,
      uid,
      token: token,
    );
    _answered[uid]![survey_id] = answered;
    return answered;
  }

  Map<String, dynamic> toJson(int survey_id) {
    if (!_answers.containsKey(survey_id)) return {};
    return {"answers": _answers[survey_id]!.map((q) => q.toJson()).toList()};
  }

  void clear(int survey_id) {
    _answers.remove(survey_id);
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

  Future<ServerResponse> postAnswer(
    int survey_id, {
    required BuildContext context,
  }) async {
    Survey? survey =
        await Provider.of<SurveyStateNotifier>(context, listen: false)
            .getSurvey(
      survey_id,
    );
    if (survey == null) {
      return ServerResponse(
        {},
        ok: false,
        statusCode: 400,
        error: Error("Survey does not exist"),
      );
    }
    ServerResponse response = await GetIt.I<AnswerService>().postAnswer(
      survey_id,
      toJson(survey_id),
      token: getToken(context),
    );
    if (response.ok) {
      AuthStateNotifier asn = Provider.of<AuthStateNotifier>(
        context,
        listen: false,
      );
      if (asn.isUser) {
        asn.setPoints(
          asn.user.points + survey.points,
        );
      }
    }
    return response;
  }
}

class QuestionAnswer {
  final int question_id;

  String _value = "";

  String get value => _value;
  void setValue(String value) => _value = value;
  bool isAnswered({isMandatory: false}) =>
      !isMandatory ? true : _value.isNotEmpty;

  Map<String, dynamic> toJson() => {
        "value": value,
        "question_id": question_id,
      };

  QuestionAnswer(this.question_id);
  factory QuestionAnswer.fromQuestion(Question question) {
    return QuestionAnswer(
      question.questionID,
    );
  }
}
