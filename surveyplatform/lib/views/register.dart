import 'package:flutter/material.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/register_container.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _welcomeVisible = false;
  @override
  void initState() {
    setState(() {
      _welcomeVisible = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool smallHeight = MediaQuery.of(context).size.height < 650;
    bool smallWidthForRow = MediaQuery.of(context).size.width < 800;
    return Scaffold(
        backgroundColor: HomePage.backgroundColor,
        body: Row(
          children: [
            smallWidthForRow
                ? SizedBox.shrink()
                : Flexible(
                    flex: 3,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              "Lag din SurveyPlatform konto",
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Image.asset("assets/join_us.jpg")
                        ],
                      ),
                    ),
                  ),
            Flexible(
              flex: 7,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        padding: smallHeight ? EdgeInsets.only(top: 20) : null,
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Lag din konto",
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    RegisterContainer(),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
