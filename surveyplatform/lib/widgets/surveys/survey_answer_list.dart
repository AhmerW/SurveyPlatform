import 'package:flutter/material.dart';
import 'package:surveyplatform/models/survey.dart';

class SurveyAnswerList extends StatefulWidget {
  final Survey survey;
  const SurveyAnswerList(this.survey);

  @override
  _SurveyAnswerListState createState() => _SurveyAnswerListState();
}

class _SurveyAnswerListState extends State<SurveyAnswerList> {
  final PageController _pageController = PageController(initialPage: 1);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.survey.questions.length,
      itemBuilder: (context, index) {
        if (index + 2 == (widget.survey.questions.length + 1)) {
          return Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    "Du har svart alle ${widget.survey.questions.length} spørsmål!",
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Send svar"),
                  ),
                ),
              ],
            ),
          );
        }
        Question question = widget.survey.questions[index];

        return Container(
          child: PhysicalModel(
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                ),
                Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
