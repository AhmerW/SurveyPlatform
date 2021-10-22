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
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            : ReorderableListView.builder(
                scrollController: _controller,
                scrollDirection: Axis.vertical,
                itemCount: nss.questions.length,
                itemBuilder: (context, index) {
                  QuestionState question = nss.questions[index];

                  return Container(
                    key: Key('${question.position - 1}'),
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: QuestionWidget(question),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    oldIndex -= 1;
                  }
                  final QuestionState _qs = nss.questions.removeAt(oldIndex);
                  _qs.question.position = newIndex + 1;
                  nss.questions.insert(newIndex, _qs);
                },
              );
      },
    );
  }
}
