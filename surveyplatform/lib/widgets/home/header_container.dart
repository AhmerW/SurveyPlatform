import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/widgets/funcs.dart';

class HomePageHeader extends StatefulWidget {
  final ItemScrollController _controller;
  const HomePageHeader(this._controller);

  @override
  _HomePageHeaderState createState() => _HomePageHeaderState();
}

class _HomePageHeaderState extends State<HomePageHeader> {
  @override
  Widget build(BuildContext context) {
    bool isLargeHeight = MediaQuery.of(context).size.height > 800;
    bool isEnoughRemaining = MediaQuery.of(context).size.height > 800;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: isLargeHeight ? 300 : 50,
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 20,
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: TitleText(
                        "Bli belønnet for å svare på spørreundersøkelser"),
                  ),
                ),
                Container(
                  height: 20,
                ),
                Material(
                  color: HomePage.backgroundColor,
                  elevation: 20,
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => LoginPage()));
                      },
                      child: Text("Begynn nå"),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Divider(
              color: Colors.orange,
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height *
              (isEnoughRemaining ? 0.5 : 0.7),
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 100),
            child: IconButton(
              iconSize: 50,
              onPressed: () {
                widget._controller
                    .scrollTo(index: 2, duration: Duration(seconds: 1));
              },
              icon: Icon(Icons.arrow_drop_down_circle_outlined),
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}