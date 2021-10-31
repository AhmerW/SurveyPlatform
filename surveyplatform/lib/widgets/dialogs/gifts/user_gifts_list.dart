import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/data/states/gift_state.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/services/auth_service.dart';
import 'package:surveyplatform/views/home.dart';

class UserGiftsListDialog extends StatefulWidget {
  const UserGiftsListDialog({Key? key}) : super(key: key);

  @override
  _UserGiftsListDialogState createState() => _UserGiftsListDialogState();
}

class _UserGiftsListDialogState extends State<UserGiftsListDialog> {
  Map<int, bool> _hovers = {};

  bool isHovering(int gift_id) =>
      _hovers.containsKey(gift_id) ? _hovers[gift_id]! : false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Mine gaver",
        style: TextStyle(color: Colors.orange),
      ),
      backgroundColor: Color(0xFF1E272E),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Consumer<AuthStateNotifier>(
          builder: (context, asn, _) {
            return Consumer<GiftStateNotifier>(
              builder: (contxet, gsn, _) {
                return FutureBuilder(
                  future:
                      gsn.getClaimed(asn.user.uid, token: getToken(context)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Item> items = (snapshot.data ?? []) as List<Item>;
                      return Container(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                color: Colors.orange,
                              ),
                            );
                          },
                          itemBuilder: (context, index) {
                            Item item = items[index];

                            return InkWell(
                              onTap: () {},
                              onHover: (isHovering) {
                                setState(() {
                                  _hovers[item.giftID] = isHovering;
                                });
                              },
                              child: PhysicalModel(
                                borderRadius: BorderRadius.circular(15),
                                shadowColor: HomePage.primaryColor,
                                color: HomePage.primaryColor,
                                elevation: isHovering(item.giftID) ? 15 : 5,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 800),
                                  child: ListTile(
                                    title: Text(
                                      item.value,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(
                                                ClipboardData(text: item.value))
                                            .then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "Gave kopiert!"))));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
