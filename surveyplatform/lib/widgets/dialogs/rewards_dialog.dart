import 'package:flutter/material.dart';

class PageRewardsDialog extends StatelessWidget {
  const PageRewardsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Belønninger"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Vi belønner våre brukere i poeng, som dere kan bruke for å veksle for blant annet gavekort.\nGavekort påfylles av våre administratorer, som også bestemmer antall poeng som skal gis på vær spørreundersøkelse.")
        ],
      ),
    );
  }
}
