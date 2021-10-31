import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/widgets/surveys/widgets/base.dart';

class NewSurveyState extends ChangeNotifier {
  final NewSurveyQuestionState qs = NewSurveyQuestionState();
  int _points = 0;
  String _title = "";
  // Update existing survey if we are editing one
  int _updateID = Survey.invalidID;

  List<QuestionState> get questions => qs.questions;
  String get title => _title;

  NewSurveyQuestionState get qss => NewSurveyQuestionState();

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  int get points => _points;
  void setPoints(int points) {
    _points = points;
    notifyListeners();
  }

  void clear() {
    _updateID = Survey.invalidID;
    _points = 0;
    _title = "";
    qs.clear();
    notifyListeners();
  }

  Survey asSurvey({bool draft: false}) {
    return Survey(_updateID,
        title: title,
        questions: qs.questions.map((qs) => qs.question).toList(),
        points: points,
        draft: draft);
  }

  void addQuestion(String widget) {
    qs.addQuestion(widget);
    notifyListeners();
  }

  void removeQuestion(int position) {
    qs.removeQuestion(position - 1);

    notifyListeners();
  }

  Future<ServerResponse> saveSurvey(BuildContext context) async {
    return await postSurvey(context, draft: true);
  }

  Future<ServerResponse> postSurvey(
    BuildContext context, {
    bool draft: false,
  }) async {
    Survey survey = asSurvey(draft: draft);
    var response = await Provider.of<SurveyStateNotifier>(
      context,
      listen: false,
    ).postSurvey(
      survey,
      Provider.of<AuthStateNotifier>(
        context,
        listen: false,
      ).token,
    );
    if (response.ok) {
      Survey? s = response.data["survey"] == null
          ? null
          : Survey.fromJson(response.data["survey"]);
      print("fetched: $s");
      Provider.of<SurveyStateNotifier>(context, listen: false).addSurvey(
        s ?? survey,
      );
      if (draft) {
        _updateID = response.data["id"] ?? Survey.invalidID;
      } else {
        clear();
      }
    }
    return response;
  }
}

class NewSurveyQuestionState {
  List<QuestionState> _questions = [];

  List<QuestionState> get questions => _questions;

  void addQuestion(String widget) {
    _questions.add(
      QuestionState(
        _questions.length + 1,
        widget: widget,
        values: getQuestionValues(widget),
      ),
    );
  }

  void removeQuestion(int index) {
    _questions.removeAt(index);
    _questions
        .forEach((question) => question.setPosition(question.position - 1));
  }

  void clear() {
    _questions.clear();
  }
}
