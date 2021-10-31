import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/views/home.dart';

class SubmitSurveyAnswerDialog extends StatefulWidget {
  final int survey_id;

  const SubmitSurveyAnswerDialog(this.survey_id);

  @override
  _SubmitSurveyAnswerDialogState createState() =>
      _SubmitSurveyAnswerDialogState();
}

class _SubmitSurveyAnswerDialogState extends State<SubmitSurveyAnswerDialog> {
  Future? _future;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _future = Provider.of<SurveyAnswerState>(
          context,
          listen: false,
        ).postAnswer(
          widget.survey_id,
          context: context,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Sender svar..",
        style: GoogleFonts.merriweather(
          color: Colors.white,
        ),
      ),
      backgroundColor: HomePage.backgroundColor,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: _future == null
            ? Container()
            : FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    ServerResponse response = snapshot.data as ServerResponse;

                    return Center(
                      child: Container(
                        child: Text(
                          response.hasError
                              ? response.error!.message
                              : response.detail,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
      ),
    );
  }
}
