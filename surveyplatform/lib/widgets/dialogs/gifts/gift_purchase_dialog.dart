import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/views/home.dart';

class GiftPurchaseDialog extends StatefulWidget {
  const GiftPurchaseDialog({Key? key}) : super(key: key);

  @override
  _GiftPurchaseDialogState createState() => _GiftPurchaseDialogState();
}

class _GiftPurchaseDialogState extends State<GiftPurchaseDialog> {
  Map<int, bool> _hoveredGifts = {};

  @override
  Widget build(BuildContext context) {
    bool isHovering(int gift_id) {
      bool? value = _hoveredGifts[gift_id];

      if (value == null) return false;
      return value;
    }

    void setHovering(int gift_id, bool value) {
      setState(() {
        _hoveredGifts[gift_id] = value;
      });
    }

    return AlertDialog(
      title: Text(
        "Gaver",
        style: GoogleFonts.merriweather(
          color: Colors.white,
        ),
      ),
      backgroundColor: HomePage.darkBackgroundColor,
      content: Container(
        child: Consumer<AuthStateNotifier>(builder: (context, asn, _) {
          return Consumer<GiftStateNotifier>(
            builder: (context, gsn, _) {
              return FutureBuilder(
                future: gsn.load(),
                builder: (context, snapshot) {
                  List<Gift> gifts = (snapshot.data ?? <Gift>[]) as List<Gift>;
                  if (gifts.isEmpty) {
                    return Center(
                      child: Text("Ingen gaver.."),
                    );
                  } else if (gifts.isNotEmpty) {
                    return Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(bottom: 20),
                              child: Text(
                                "Du har ${asn.user.points} poeng",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                children: gifts
                                    .map(
                                      (gift) => InkWell(
                                        onTap: () {
                                          if (gift.price > asn.user.points) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Du har ikke nok poeng til å kjøpe denne gaven"),
                                              ),
                                            );
                                          } else if (gift.itemCount <= 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Ingen gavekort av denne type på lager.")));
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Kjøper gave.."),
                                                content: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: FutureBuilder(
                                                    future: gsn.claimAnyItem(
                                                      gift,
                                                      uid: asn.user.uid,
                                                      token: getToken(context),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        ServerResponse
                                                            response =
                                                            snapshot.data
                                                                as ServerResponse;

                                                        return Center(
                                                          child: Text(
                                                            response.hasError
                                                                ? response
                                                                    .error!
                                                                    .message
                                                                : response
                                                                    .detail,
                                                          ),
                                                        );
                                                      }
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        onHover: (hover) =>
                                            setHovering(gift.giftID, hover),
                                        child: AnimatedPhysicalModel(
                                          shape: BoxShape.rectangle,
                                          duration: Duration(milliseconds: 250),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          elevation:
                                              isHovering(gift.giftID) ? 15 : 5,
                                          color: HomePage.darkBackgroundColor,
                                          shadowColor: isHovering(gift.giftID)
                                              ? HomePage.primaryColor
                                              : Colors.black,
                                          child: Container(
                                            constraints:
                                                BoxConstraints(maxHeight: 200),
                                            child: Column(
                                              children: [
                                                Align(
                                                  child: Text(
                                                    gift.title,
                                                    style: GoogleFonts
                                                        .merriweather(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(top: 20),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 15,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "${gsn.getUnclaimed(gift.giftID).length}x på lager\n\n",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              gift.description,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                                Spacer(),
                                                Divider(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.emoji_events,
                                                        color: HomePage
                                                            .primaryColor),
                                                    Container(
                                                      child: Text(
                                                          "${gift.price}p",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: HomePage
                                                                .primaryColor,
                                                          )),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ));
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
