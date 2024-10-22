import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/login_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LoginPage> {
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
                      GoRouter.of(context).go("/home");
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        "assets/logo.png",
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
                        "Velkommen",
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
            LoginContainer(),
          ],
        ),
      ),
    );
  }
}
