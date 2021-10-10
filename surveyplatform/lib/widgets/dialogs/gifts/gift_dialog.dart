import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/views/home.dart';
import 'package:surveyplatform/widgets/dialogs/gifts/gift_items_dialog.dart';

class GiftDialog extends StatefulWidget {
  const GiftDialog({Key? key}) : super(key: key);

  @override
  _GiftDialogState createState() => _GiftDialogState();
}

class _GiftDialogState extends State<GiftDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HomePage.backgroundColor,
      title: Text("Gaver", style: TextStyle(color: Colors.white)),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Scaffold(
          backgroundColor: HomePage.backgroundColor,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
          ),
          body: FutureBuilder(
            future:
                Provider.of<GiftStateNotifier>(context, listen: false).load(),
            builder: (contxet, snapshot) {
              List<Gift> gifts = (snapshot.data ?? <Gift>[]) as List<Gift>;
              if (gifts.isNotEmpty) {
                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    Gift gift = gifts[index];
                    return InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => GiftItemsDialog(gift));
                      },
                      onHover: (hover) {},
                      child: Card(
                        color: HomePage.darkBackgroundColor,
                        elevation: 15,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                gift.title,
                                style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                    "${gift.itemCount}x in stock.\n${gift.description}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.delete)),
                                  IconButton(
                                      onPressed: () {}, icon: Icon(Icons.edit))
                                ],
                              ),
                            ),
                            Text(
                              "${gift.price}p",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: HomePage.primaryColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}