import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveyplatform/widgets/funcs.dart';
import 'package:surveyplatform/widgets/home/header_container.dart';
import 'package:surveyplatform/widgets/home/info_card.dart';

class HomePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            // Center(child: CustomDivider(context)),
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    height: 100,
                  ),
                  TitleText("Tjen penger på få minutter"),
                  SingleChildScrollView(
                    child: RewardCard(),
                    scrollDirection: Axis.vertical,
                  ),
                  InfoCardContainer(
                    cards: [
                      /* InfoCard("Lett", asset: "stock1.png"), */
                      InfoCard("Hjelpsomt", asset: "stock2.png"),
                      InfoCard("Lønnsomt", asset: "stock3.png"),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
