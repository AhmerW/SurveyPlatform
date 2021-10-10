import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/views/home.dart';

class GiftItemsDialog extends StatefulWidget {
  final Gift gift;
  const GiftItemsDialog(this.gift);

  @override
  _GiftDialogState createState() => _GiftDialogState();
}

class _GiftDialogState extends State<GiftItemsDialog> {
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
                Provider.of<GiftStateNotifier>(context, listen: false).getItems(
              widget.gift.giftID,
              token: Provider.of<AuthStateNotifier>(
                context,
                listen: false,
              ).token,
            ),
            builder: (contxet, snapshot) {
              List<Item> items = (snapshot.data ?? <Item>[]) as List<Item>;
              if (items.isEmpty) {
                return Center(
                  child: Text("No items"),
                );
              }
              if (items.isNotEmpty)
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Item item = items[index];
                    return InkWell(
                      onTap: () {},
                      onHover: (hover) {},
                      child: Card(
                        color: HomePage.darkBackgroundColor,
                        elevation: 15,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                item.value,
                                style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                          ],
                        ),
                      ),
                    );
                  },
                );

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
