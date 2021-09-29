import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:surveyplatform/main.dart';

import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/tos.dart';
import 'package:surveyplatform/widgets/dialogs/about_dialog.dart';
import 'package:surveyplatform/widgets/dialogs/rewards_dialog.dart';
import 'package:surveyplatform/widgets/home/body_container.dart';
import 'package:surveyplatform/widgets/home/header_container.dart';

Widget navButton(
  String content,
  void Function() onPressed,
) {
  return Container(
    child: TextButton(
      child: Text(content,
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.w700,
          )),
      onPressed: onPressed,
    ),
  );
}

class HomePage extends StatefulWidget {
  static const backgroundColor = Color(0xFF386C8C);
  static const darkBackgroundnColor = Color(0xFF1B2B38);
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ItemScrollController _controller = ItemScrollController();
  ItemPositionsListener _listener = ItemPositionsListener.create();

  double appBarElevation = 0;

  @override
  void initState() {
    super.initState();

    _listener.itemPositions.addListener(() {
      setState(() {
        appBarElevation =
            _listener.itemPositions.value.first.itemLeadingEdge == 0 ? 0 : 16;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [
      HomePageHeader(_controller),
      HomePageBody(),
      Footer(HomePage.backgroundColor)
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: appBarElevation,
        backgroundColor: Color(0xFF4683A6),
        title: Image.asset(
          "logotext.png",
          fit: BoxFit.cover,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                navButton("OM", () {
                  showDialog(
                      context: context,
                      builder: (context) => PageAboutDialog());
                }),
                navButton("BELØNNINGER", () {
                  showDialog(
                      context: context,
                      builder: (context) => PageRewardsDialog());
                }),
                navButton("VILKÅR", () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => TOSPage()));
                })
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  24,
                ),
                color: Colors.transparent),
            margin: EdgeInsets.all(5),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: Icon(Icons.login),
            ),
          )
        ],
      ),
      backgroundColor: Color(0xFF4683A6),
      body: ScrollablePositionedList.builder(
        itemScrollController: _controller,
        itemPositionsListener: _listener,
        itemCount: content.length,
        itemBuilder: (context, index) {
          return content[index];
        },
      ),
    );
  }
}
