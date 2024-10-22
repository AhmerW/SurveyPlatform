import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:surveyplatform/data/network.dart';
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
    _surveys.sort((current, next) => next.surveyID.compareTo(next.surveyID));
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

  Future<Survey?> getSurvey(int survey_id) async {
    try {
      return (await getSurveys()).singleWhere(
        (survey) => survey.surveyID == survey_id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Survey?> fetchSurvey(int survey_id) async {
    return locator<SurveyService>().getSurvey(survey_id);
  }

  Future<ServerResponse> postSurvey(Survey survey, String token) async {
    return await locator<SurveyService>().postSurvey(survey, token);

    /* Survey? surveyout = GetIt.I<SurveyService>().surveyFromResponse(response); */
  }

  Future<ServerResponse> deleteSurvey(Survey survey, String token) async {
    ServerResponse response = await locator<SurveyService>().deleteSurvey(
      survey.surveyID,
      token,
    );
    if (response.ok) {
      _surveys.removeWhere((s) => s.surveyID == survey.surveyID);
      notifyListeners();
    }
    return response;
  }
}
