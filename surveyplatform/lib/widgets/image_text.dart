import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageText extends StatefulWidget {
  final bool imageAtRight;
  final String image;
  final String title;
  final String text;
  const ImageText(
    this.imageAtRight, {
    required this.image,
    required this.title,
    required this.text,
  });

  @override
  _ImageTextState createState() => _ImageTextState();
}

class _ImageTextState extends State<ImageText> {
  @override
  Widget build(BuildContext context) {
    final bool isSmallWidth = MediaQuery.of(context).size.width < 1200;
    Widget textWidget = Container(
      padding: EdgeInsets.only(right: 50),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.notoSans(color: Colors.white),
          children: [
            TextSpan(
              text: "${widget.title}\n\n\n",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            TextSpan(
              text: widget.text,
              style: TextStyle(fontSize: 15),
            )
          ],
        ),
      ),
    );
    Widget image = Container(
      padding: !widget.imageAtRight ? EdgeInsets.only(right: 100) : null,
      child: Image.asset(
        widget.image,
        fit: BoxFit.contain,
      ),
    );

    return Flex(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      direction: isSmallWidth ? Axis.vertical : Axis.horizontal,
      children: isSmallWidth
          ? [
              image,
              Container(
                  padding: EdgeInsets.only(bottom: 20), child: textWidget),
            ]
          : widget.imageAtRight
              ? [textWidget, image]
              : [image, textWidget],
    );
  }
}
