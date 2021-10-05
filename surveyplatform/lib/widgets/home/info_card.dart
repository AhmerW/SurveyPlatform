import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyplatform/views/home.dart';

class InfoCard {
  final String title;
  final String asset;
  const InfoCard(this.title, {required this.asset});
}

// Container

class InfoCardContainer extends StatefulWidget {
  final List<InfoCard> cards;

  InfoCardContainer({required this.cards});

  @override
  _InfoCardContainerState createState() => _InfoCardContainerState();
}

class _InfoCardContainerState extends State<InfoCardContainer> {
  @override
  Widget build(BuildContext context) {
    bool isSmallWidth = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      scrollDirection: isSmallWidth ? Axis.vertical : Axis.horizontal,
      child: Flex(
        direction: isSmallWidth ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.cards
            .asMap()
            .map(
              (index, card) => MapEntry(
                  index,
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text(
                          card.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.anton(
                            fontWeight: FontWeight.w400,
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                        PhysicalModel(
                          elevation: 20,
                          color: Color(0xFF384955),
                          child: Container(
                            margin: EdgeInsets.all(30),
                            child: Image.asset(
                              card.asset,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            )
            .values
            .toList(),
      ),
    );
  }
}
