import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Divider(
        color: Colors.orange,
      ),
    );
  }
}

Text TitleText(String content) {
  return Text(
    content,
    textAlign: TextAlign.center,
    style: GoogleFonts.merriweather(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );
}

class RewardCardItem extends StatelessWidget {
  final String content;
  final IconData icon;
  const RewardCardItem(this.content, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Text(
            content,
            style: GoogleFonts.lato(fontStyle: FontStyle.italic),
          ),
          Icon(icon),
        ],
      ),
    );
  }
}

class RewardCard extends StatelessWidget {
  const RewardCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RewardCardItem("Svar", Icons.post_add),
            Expanded(
              child: Divider(
                color: Colors.black,
                thickness: 1,
              ),
            ),
            RewardCardItem("Vent", Icons.hourglass_empty),
            Expanded(
                child: Divider(
              thickness: 1,
              color: Colors.black,
            )),
            RewardCardItem("Få poeng", Icons.card_giftcard)
          ],
        ),
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {
  final void Function() onPressed;
  final String content;
  const SimpleButton(this.content, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        content,
        style: GoogleFonts.merriweather(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
