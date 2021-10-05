import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQContainer extends StatelessWidget {
  const FAQContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000,
      child: Column(
        children: [
          Divider(),
          Container(
            alignment: Alignment.center,
            child: Text(
              "FAQ",
              style: GoogleFonts.merriweather(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
