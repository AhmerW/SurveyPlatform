import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/widgets/question.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({Key? key}) : super(key: key);

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewSurveyState>(
      builder: (context, nss, _) {
        return nss.questions.isEmpty
            ? Center(
                child: Text(
                  "Du har ikke lagt til noen spørsmål ..",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: nss.questions.length,
                itemBuilder: (context, index) {
                  QuestionState question = nss.questions[index];
                  return QuestionWidget(question);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              );
      },
    );
  }
}
