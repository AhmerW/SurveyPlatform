import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/services/survey_service.dart';

class SurveyStateNotifier extends ChangeNotifier {
  List<Survey> _surveys = [];
  List<Survey> _drafts = [];
  bool _fetched = false;
  bool _fetchedDrafts = false;

  void sortSurveys() {
    _surveys.sort((current, next) => next.surveyid.compareTo(next.surveyid));
  }

  void addSurvey(Survey survey) => _surveys.add(survey);

  Future<List<Survey>> reloadSurveys() async {
    _surveys = await locator<SurveyService>().getSurveys();
    notifyListeners();
    return _surveys;
  }

  Future<List<Survey>> getSurveys() async {
    if (!_fetched) {
      await reloadSurveys();
      _fetched = true;
    }
    return _surveys;
  }

  Future<ServerResponse> postSurvey(Survey survey, String token) async {
    return await locator<SurveyService>().postSurvey(survey, token);

    /* Survey? surveyout = GetIt.I<SurveyService>().surveyFromResponse(response); */
  }
}
