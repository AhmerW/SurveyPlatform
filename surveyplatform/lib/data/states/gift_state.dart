import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/services/gift_service.dart';

class GiftStateNotifier extends ChangeNotifier {
  bool _loaded = false;
  List<Gift> _gifts = [];
  Map<int, List<Item>> _items = {};

  List<Gift> get gifts => _gifts;

  void addGift(Gift gift) {
    _gifts.add(gift);
    notifyListeners();
  }

  Future<List<Gift>> load() async {
    if (!_loaded) {
      _loaded = true;
      _gifts = await GetIt.I<GiftService>().getGifts();
    }
    return _gifts;
  }

  Future<List<Item>> getItems(int gift_id,
      {required String token, String type: "all"}) async {
    if (_items.containsKey(gift_id)) return _items[gift_id]!;

    _items[gift_id] = await GetIt.I<GiftService>()
        .getGiftItems(gift_id, type: type, token: token);
    return _items[gift_id]!;
  }
}
