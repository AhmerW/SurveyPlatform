import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:surveyplatform/data/states/question_state.dart';
import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

class RatingScaleWidget extends StatefulWidget {
  final QuestionState question;
  const RatingScaleWidget(this.question);

  @override
  _RatingScaleWidgetState createState() => _RatingScaleWidgetState();
}

class _RatingScaleWidgetState extends State<RatingScaleWidget> {
  int _minValue = 0;
  int _maxValue = 10;

  int _selected = -1;

  void setMaxValue(int value) {
    setState(() {
      _maxValue = value;
      widget.question.values["maxValue"] = _maxValue;
    });
  }

  void setMinValue(int value) {
    setState(() {
      _minValue = value;
      widget.question.values["minValue"] = _minValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 25,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _maxValue,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selected = index;
                    });
                  },
                  child: AnimatedContainer(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    width: 25,
                    height: 25,
                    duration: Duration(milliseconds: 400),
                    child: Center(
                        child: Text(
                      "${index + _minValue}",
                      textAlign: TextAlign.center,
                    )),
                    decoration: BoxDecoration(
                      color: _selected == index ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return VerticalDivider();
              },
            ),
          ),
        ),
        Divider(),
        Center(child: Text("Instillinger for RatingScale")),
        SingleValueField(
          "Antall verdier",
          InputFieldState(
              fieldWidth: 0.2,
              hintText: "$_maxValue",
              inputType: TextInputType.number),
          onValidate: (value) {
            int? val = int.tryParse(value);
            if (val == null) return false;
            return val <= 100;
          },
          onSubmit: (value) => setMaxValue(int.parse(value)),
        ),
        SingleValueField(
          "Start verdi",
          InputFieldState(
              fieldWidth: 0.2,
              hintText: "$_minValue",
              inputType: TextInputType.number),
          onValidate: (value) {
            return int.tryParse(value) != null;
          },
          onSubmit: (value) => setMinValue(int.parse(value)),
        )
      ],
    );
  }
}
