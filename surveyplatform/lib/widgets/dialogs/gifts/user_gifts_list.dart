import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Mine gaver"),
      backgroundColor: HomePage.darkBackgroundColor,
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
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            Item item = items[index];

                            return PhysicalModel(
                              borderRadius: BorderRadius.circular(20),
                              shadowColor: HomePage.backgroundColor,
                              color: HomePage.backgroundColor,
                              elevation: 20,
                              child: ListTile(
                                title: Text(item.value),
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
