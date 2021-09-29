import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/surveys/survey_answer_list.dart';

class SurveyAnswerPage extends StatefulWidget {
  final Survey survey;

  const SurveyAnswerPage(this.survey);

  @override
  _SurveyAnswerPageState createState() => _SurveyAnswerPageState();
}

class _SurveyAnswerPageState extends State<SurveyAnswerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              widget.survey.title,
              style: GoogleFonts.merriweather(
                  fontSize: 30, fontStyle: FontStyle.italic),
            ),
          ),
          RichText(
              text: TextSpan(
            children: [
              TextSpan(text: "Belønning: "),
              TextSpan(text: "${widget.survey.points}p")
            ],
          )),
          /* Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: _darkMode
                    ? Icon(Icons.brightness_4)
                    : Icon(Icons.dark_mode_outlined),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
              ),
            ],
          ), */
          Divider(),
          Expanded(
            child: Container(
              child: SurveyAnswerList(
                widget.survey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
