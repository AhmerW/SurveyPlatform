import 'package:flutter/material.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/ver_container.dart';

class VerificationPage extends StatefulWidget {
  final String token;
  const VerificationPage(this.token);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
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
                        "Vennligst verifiser deg for å fortsette",
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
            VerContainer(widget.token),
          ],
        ),
      ),
    );
  }
}
