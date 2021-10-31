import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/survey_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/surveys/survey_answer.dart';

class SurveyIDAnswerPage extends StatefulWidget {
  final int survey_id;
  const SurveyIDAnswerPage(this.survey_id);

  @override
  _SurveyIDAnswerPageState createState() => _SurveyIDAnswerPageState();
}

class _SurveyIDAnswerPageState extends State<SurveyIDAnswerPage> {
  Future? _future;
  Survey? _survey;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _future = Provider.of<SurveyStateNotifier>(context, listen: false)
            .fetchSurvey(
          widget.survey_id,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _future == null
            ? CircularProgressIndicator()
            : FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  print(snapshot.data);
                  _survey =
                      snapshot.data == null ? null : (snapshot.data as Survey);
                  print("survey: $_survey");
                  if (_survey != null)
                    return SurveyAnswerPage(SurveyAnswerPageData(_survey!));
                  return Text("No survey with that ID found.");
                },
              ),
      ),
    );
  }
}
