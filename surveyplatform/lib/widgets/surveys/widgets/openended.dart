import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class OpenEndedWidget extends StatefulWidget {
  final QuestionState question;
  const OpenEndedWidget(this.question);

  @override
  _OpenEndedWidgetState createState() => _OpenEndedWidgetState();
}

class _OpenEndedWidgetState extends State<OpenEndedWidget> {
  String _hint = "";
  int _maxChars = 250;
  int _minChars = 0;

  void setMaxchars(int value) {
    setState(() {
      _maxChars = value;
      widget.question.values["maxChars"] = value;
    });
  }

  void setMinChars(int value) {
    setState(() {
      _minChars = value;
      widget.question.values["minChars"] = value;
    });
  }

  void setHint(String value) {
    setState(() {
      _hint = value;
      widget.question.values["hint"] = value;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _hint = widget.question.values["hint"];
        _maxChars = widget.question.values["maxChars"];
        _minChars = widget.question.values["minChars"];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),
        SingleValueField(
          "Hint tekst",
          InputFieldState(fieldWidth: 0.2, hintText: "$_hint"),
          onValidate: (value) => value.length < 1024,
          onSubmit: (value) => setHint(value),
        ),
        SingleValueField(
          "Minimum ord",
          InputFieldState(fieldWidth: 0.2, hintText: "$_minChars"),
          onValidate: (value) {
            int? val = int.tryParse(value);
            if (val == null) return false;
            return val < _maxChars && val > 0;
          },
          onSubmit: (value) => setMinChars(int.parse(value)),
        ),
        SingleValueField(
          "Maks ord",
          InputFieldState(fieldWidth: 0.2, hintText: "$_maxChars"),
          onValidate: (value) {
            int? val = int.tryParse(value);
            if (val == null) return false;
            return val > 0 && val < 2000;
          },
          onSubmit: (value) => setMaxchars(int.parse(value)),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          child: TextButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("Forhåndsvisning"),
                      content: TextField(
                        maxLength: _maxChars,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          hintText: _hint,
                        ),
                      ),
                    )),
            child: Text("Forhåndsvis"),
          ),
        )
      ],
    );
  }
}
