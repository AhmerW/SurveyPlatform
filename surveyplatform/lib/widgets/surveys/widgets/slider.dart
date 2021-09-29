import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:surveyplatform/data/states/question_state.dart';

import 'package:surveyplatform/widgets/field.dart';
import 'package:surveyplatform/widgets/surveys/widgets/base.dart';
import 'package:surveyplatform/widgets/surveys/widgets/value_field.dart';

// Editable widget
class SliderWidget extends StatefulWidget {
  final QuestionState question;

  SliderWidget(this.question);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int _divisions = 100;
  double _min = 0;
  double _max = 100;
  double _value = 50;

  double getMin() {
    return widget.question.values["min"] ?? 0;
  }

  double getMax() {
    return widget.question.values["max"] ?? 100;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _min = getMin();
        _max = getMax();
        _value = _min;
        print("min: $_min, max: $_max, value: $_value");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _value,
          min: _min,
          max: _max,
          label: "$_value",
          divisions: _divisions,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
          },
        ),
        Divider(),
        Text("Instillinger for slider"),
        // Minimum value
        SingleValueField(
          "Minimum verdi",
          InputFieldState(
            fieldWidth: 0.2,
            hintText: "$_min",
          ),
          onValidate: (value) {
            int? val = int.tryParse(value);
            if (val == null) {
              return false;
            }
            return val < _max;
          },
          onSubmit: (value) {
            int? val = int.tryParse(value);
            if (val != null)
              setState(() {
                widget.question.values["min"] = val;
                _min = val as double;
                _value = _min;
              });
          },
        ),
        // Maximum value
        SingleValueField(
          "Maksimum verdi",
          InputFieldState(
            fieldWidth: 0.2,
            hintText: "$_max",
          ),
          onValidate: (value) {
            int? val = int.tryParse(value);
            if (val == null) {
              return false;
            }
            return val > _min && val > 0;
          },
          onSubmit: (value) {
            int? val = int.tryParse(value);
            if (val != null)
              setState(() {
                widget.question.values["max"] = val;
                _max = val as double;
                _value = _max;
              });
          },
        ),
        SingleValueField(
          "Divisjoner",
          InputFieldState(
            hintText: "$_divisions",
            fieldWidth: 0.2,
          ),
          onSubmit: (value) {
            print("divisions: $value");
            int? divisions = int.tryParse(value);
            if (divisions != null) {
              setState(() {
                _divisions = divisions;
              });
            }
          },
          onValidate: (value) => int.tryParse(value) != null,
        ),
        Divider(),
      ],
    );
  }
}
