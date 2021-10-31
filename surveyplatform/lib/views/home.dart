import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:surveyplatform/main.dart';

import 'package:surveyplatform/views/login.dart';
import 'package:surveyplatform/views/register.dart';
import 'package:surveyplatform/views/tos.dart';
import 'package:surveyplatform/widgets/dialogs/about_dialog.dart';
import 'package:surveyplatform/widgets/dialogs/rewards_dialog.dart';
import 'package:surveyplatform/widgets/home/body_container.dart';
import 'package:surveyplatform/widgets/home/faq_container.dart';
import 'package:surveyplatform/widgets/home/header_container.dart';
import 'package:surveyplatform/widgets/image_text.dart';

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

Widget drawerListTile(String content, void Function() onPressed) {
  return ListTile(
    onTap: onPressed,
    title: Text(content,
        style: GoogleFonts.merriweather(
            color: Colors.white, fontWeight: FontWeight.bold)),
  );
}

class HomePage extends StatefulWidget {
  static const backgroundColor = Color(0xFF384955);
  static const darkBackgroundColor = Color(0xFF24292e);
  static const primaryColor = Color(0xFFe99a27);

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

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
    bool isSmallWidth = MediaQuery.of(context).size.width <= 962;
    bool isVerySmallWidth = MediaQuery.of(context).size.width <= 732;

    Image logo = Image.asset(
      "assets/logotext.png",
      fit: BoxFit.cover,
    );

    final List<Widget> content = [
      HomePageHeader(_controller),
      HomePageBody(),
      Column(
        children: [
          ImageText(true,
              image: "assets/stock1-t.png",
              title: "Lyst på forte penger?",
              text:
                  "Det skal gå fort å svare på våre undersøkelser.\nSamtidig sørger vi får at dere får så mye ut av det."),
          ImageText(
            false,
            image: "assets/stock2.jpg",
            title: "Hjelper dere så mye som mulig",
            text:
                "Våre undersøkelser gir oss ett godt inblikk over markedet.\nDet betyr at ditt svar vil ha ett stort innvirkning på samfunnet!",
          )
        ],
      ),
      Container(
        height: 300,
        color: Color(0xFF1E272E),
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hva venter du på?",
              style: GoogleFonts.merriweather(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 50),
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go("/login");
                },
                child: Row(
                  children: [
                    Text("Begynn å tjen penger!",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_right_alt_outlined),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      FAQContainer()
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: appBarElevation,
        backgroundColor: HomePage.backgroundColor,
        centerTitle: true,
        leading: !isSmallWidth
            ? SizedBox.shrink()
            : Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              }),
        title: isSmallWidth
            ? logo
            : Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    logo,
                    Spacer(),
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
                    }),
                    Spacer(),
                  ],
                ),
              ),
        actions: [
          !isVerySmallWidth
              ? Container(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          onPressed: () => GoRouter.of(context).push("/login"),
                          child: Text("Logg inn"),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () =>
                              GoRouter.of(context).push("/register"),
                          child: Text("Lag konto"),
                        ),
                      )
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      backgroundColor: HomePage.backgroundColor,
      drawer: Drawer(
        key: _key,
        child: Container(
          color: HomePage.darkBackgroundColor,
          child: ListView(
            children: [
              drawerListTile("Om oss", () {
                showDialog(
                    context: context, builder: (context) => PageAboutDialog());
              }),
              drawerListTile("Belønninger", () {
                showDialog(
                    context: context,
                    builder: (context) => PageRewardsDialog());
              }),
              drawerListTile("Vilkår og betingelser", () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TOSPage()));
              }),
              isVerySmallWidth
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: OutlinedButton(
                                onPressed: () =>
                                    GoRouter.of(context).go("/login"),
                                child: Text("Logg inn")),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => RegisterPage()));
                                },
                                child: Text("Lag konto")),
                          )
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
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
