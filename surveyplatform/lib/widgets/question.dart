import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/surveys/widgets/base.dart';

class QuestionWidget extends StatefulWidget {
  final QuestionState question;
  const QuestionWidget(this.question);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    QuestionState question = widget.question;
    return ChangeNotifierProvider<QuestionState>.value(
      value: question,
      key: ValueKey(question),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        height: 500,
        child: PhysicalModel(
          color: HomePage.backgroundColor,
          elevation: 20,
          child: Container(
            padding: EdgeInsets.all(30),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text("Spørsmål ${question.position}"),
                      ),
                      IconButton(
                        onPressed: () {
                          Provider.of<NewSurveyState>(context, listen: false)
                              .removeQuestion(question.position);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Skriv spørsmålet her",
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      onChanged: (_) =>
                          question.setQuestionText(_textController.text),
                    ),
                  ),
                  Divider(),
                  Expanded(child: getSurveyWidget(question)),
                  Divider(),
                  CheckboxListTile(
                    title: Text("Er spørsmålet obligatorisk?"),
                    value: question.mandatory,
                    secondary: Icon(Icons.priority_high),
                    onChanged: (value) {
                      if (value is bool)
                        setState(() {
                          question.setMandatory(value);
                        });
                      ;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
