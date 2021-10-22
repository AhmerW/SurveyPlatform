import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/survey_create_state.dart';
import 'package:surveyplatform/models/survey.dart';
import 'package:surveyplatform/views/home.dart';

import 'package:surveyplatform/widgets/surveys/widgets/base.dart';
import 'package:surveyplatform/widgets/surveys/widgets/slider.dart';

class SurveyCreateSurveyWidgetList extends StatefulWidget {
  const SurveyCreateSurveyWidgetList({Key? key}) : super(key: key);

  @override
  _SurveyCreateSurveyWidgetListState createState() =>
      _SurveyCreateSurveyWidgetListState();
}

class _SurveyCreateSurveyWidgetListState
    extends State<SurveyCreateSurveyWidgetList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        String item = surveyWidgetsList[index];
        return Column(
          children: [
            PhysicalModel(
              color: HomePage.primaryColor,
              elevation: 20,
              child: ListTile(
                title: Text(
                  item,
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        NewSurveyState nss = Provider.of<NewSurveyState>(
                          context,
                          listen: false,
                        );

                        nss.addQuestion(item);
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemCount: surveyWidgetsList.length,
    );
  }
}
