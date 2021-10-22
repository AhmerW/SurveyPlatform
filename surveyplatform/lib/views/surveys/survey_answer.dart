import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/survey_answer_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/surveys/survey_answer_list.dart';

class SurveyAnswerPage extends StatefulWidget {
  final Survey survey;
  final bool preview;

  const SurveyAnswerPage(this.survey, {this.preview: false});

  @override
  _SurveyAnswerPageState createState() => _SurveyAnswerPageState();
}

class _SurveyAnswerPageState extends State<SurveyAnswerPage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        Provider.of<SurveyAnswerState>(context, listen: false).fromQuestions(
          widget.survey.surveyID,
          widget.survey.questions,
        );
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePage.backgroundColor,
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
                  color: Colors.white,
                  fontSize: 30,
                  fontStyle: FontStyle.italic),
            ),
          ),
          RichText(
              text: TextSpan(
            style: TextStyle(
              color: Colors.white,
            ),
            children: [
              TextSpan(text: "Belønning: "),
              TextSpan(
                  text: "${widget.survey.points}p",
                  style: TextStyle(fontStyle: FontStyle.italic))
            ],
          )),
          Container(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back)),
          ),
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
