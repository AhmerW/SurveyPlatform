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
    return Scaffold(
      backgroundColor: HomePage.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            smallHeight
                ? SizedBox.shrink()
                : InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => HomePage()));
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        "logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            Center(
              child: Container(
                padding: smallHeight ? EdgeInsets.only(top: 20) : null,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _welcomeVisible ? 1.0 : 0,
                      duration: const Duration(seconds: 2),
                      child: Text(
                        "Lag din SurveyPlatform konto",
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            RegisterContainer(),
          ],
        ),
      ),
    );
  }
}
