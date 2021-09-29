import 'package:flutter/material.dart';

class SurveySearchContainer extends StatefulWidget {
  const SurveySearchContainer({Key? key}) : super(key: key);

  @override
  _SurveySearchContainerState createState() => _SurveySearchContainerState();
}

class _SurveySearchContainerState extends State<SurveySearchContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      child: PhysicalModel(
        color: Color(0xFF2B4459),
        child: Container(
          child: Column(
            children: [
              Text("sort"),
            ],
          ),
        ),
      ),
    );
  }
}
