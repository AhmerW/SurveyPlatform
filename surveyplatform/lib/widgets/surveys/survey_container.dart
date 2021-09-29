import 'package:flutter/material.dart';
import 'package:surveyplatform/widgets/surveys/survey_list.dart';

class SurveyContainer extends StatefulWidget {
  const SurveyContainer({Key? key}) : super(key: key);

  @override
  _SurveyContainerState createState() => _SurveyContainerState();
}

class _SurveyContainerState extends State<SurveyContainer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 500,
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Column(
            children: [
              Divider(
                color: Colors.white,
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 200,
                ),
                child: Expanded(
                  child: SurveyList(),
                ),
              ),
              Divider(
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
