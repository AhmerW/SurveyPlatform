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
  _GiftItemsDialogState createState() => _GiftItemsDialogState();
}

class _GiftItemsDialogState extends State<GiftItemsDialog> {
  String? error;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: HomePage.backgroundColor,
      title: Text("Liste over gavekort", style: TextStyle(color: Colors.white)),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Scaffold(
            backgroundColor: HomePage.backgroundColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (contxet) => _GiftCreateItemDialog(widget.gift),
                );
              },
              child: Icon(Icons.add),
            ),
            body: Consumer<GiftStateNotifier>(builder: (context, gsn, _) {
              return Column(
                children: [
                  Flexible(
                      flex: 5,
                      child: error == null
                          ? SizedBox.shrink()
                          : Container(
                              child: Text(error!,
                                  style: TextStyle(color: Colors.red)))),
                  Flexible(
                      flex: 10,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              gsn.refreshItems(widget.gift,
                                  token: getToken(context));
                            });
                          },
                          icon: Icon(Icons.refresh),
                        ),
                      )),
                  Flexible(
                    flex: 85,
                    child: FutureBuilder(
                      future: gsn.getItems(
                        widget.gift.giftID,
                        token: Provider.of<AuthStateNotifier>(
                          context,
                          listen: false,
                        ).token,
                      ),
                      builder: (contxet, snapshot) {
                        List<Item> items =
                            (snapshot.data ?? <Item>[]) as List<Item>;
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
                                                onPressed: () {
                                                  gsn
                                                      .deleteGiftItem(
                                                    item,
                                                    token: getToken(context),
                                                  )
                                                      .then(
                                                    (response) {
                                                      if (response.hasError) {
                                                        setState(
                                                          () {
                                                            error = response
                                                                .error!.message;
                                                          },
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                                icon: Icon(Icons.delete)),
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
                ],
              );
            })),
      ),
    );
  }
}

class _GiftCreateItemDialog extends StatefulWidget {
  final Gift gift;
  const _GiftCreateItemDialog(this.gift);

  @override
  State<_GiftCreateItemDialog> createState() => _GiftCreateItemDialogState();
}

class _GiftCreateItemDialogState extends State<_GiftCreateItemDialog> {
  final TextEditingController _controller = TextEditingController();
  String? error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Legg til gavekort"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          error == null
              ? SizedBox.shrink()
              : Text(error!,
                  style: TextStyle(
                    color: Colors.red,
                  )),
          TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Skriv inn gavekort"),
          ),
          OutlinedButton(
            onPressed: () {
              GiftStateNotifier gss =
                  Provider.of<GiftStateNotifier>(context, listen: false);

              gss
                  .createGiftItem(
                widget.gift.giftID,
                value: _controller.text,
                token: getToken(context),
              )
                  .then((value) {
                if (value.ok) {
                  print("Value is OK");

                  Navigator.pop(context);
                } else if (value.hasError) {
                  setState(() {
                    this.error = value.error!.message;
                  });
                }
              });
            },
            child: Text("Legg til"),
          )
        ],
      ),
    );
  }
}
