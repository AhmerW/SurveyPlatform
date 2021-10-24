import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/main.dart';
import 'package:surveyplatform/models/gift.dart';
import 'package:surveyplatform/services/gift_service.dart';

class GiftStateNotifier extends ChangeNotifier {
  bool _loaded = false;
  List<Gift> _gifts = [];
  Map<int, List<Item>> _items = {}; // gift : item
  Map<int, List<Item>> _claimed = {};

  List<Gift> get gifts => _gifts;

  void refresh() async {
    print("rfreshisssng");
    _loaded = false;
    _gifts.clear();
    _items.clear();
    await load();
    notifyListeners();
  }

  List<Item> getUnclaimed(int gift_id) {
    if (!_items.containsKey(gift_id)) return [];
    return _items[gift_id]!.where((item) => !item.claimed).toList();
  }

  // CLAIMS

  Future<List<Item>> getClaimed(int uid, {required String token}) async {
    if (_claimed.containsKey(uid)) return _claimed[uid]!;
    _claimed[uid] = await locator<GiftService>().getUserClaimed(token: token);
    return _claimed[uid]!;
  }

  void updateClaimed(Item item, int uid) {
    if (_claimed.containsKey(uid)) {
      _claimed[uid]!.add(item);
    }
    if (_items.containsKey(item.giftID)) {
      _items[item.giftID]!.forEach((i) {
        if (i.itemID == item.itemID) {
          i.claimed = true;
          i.claimedBy = uid;
        }
      });
    }
  }

  Future<ServerResponse> claimAnyItem(
    Gift gift, {
    required int uid,
    required String token,
  }) async {
    ServerResponse response = await locator<GiftService>().claimAnyGiftItem(
      gift,
      token: token,
    );
    if (response.ok) {
      Map<String, dynamic>? item_json = response.data["item"];
      if (item_json != null) {
        Item item = Item.fromJson(item_json);
        updateClaimed(item, uid);
      }
    }

    return response;
  }

  // CLAIMS END

  Future<List<Item>> refreshItems(Gift gift, {required String token}) async {
    return await getItems(
      gift.giftID,
      token: token,
      force: true,
    );
  }

  void addGift(Gift gift) {
    _gifts.add(gift);
    notifyListeners();
  }

  void addGiftItem(Item item) {
    print("ADDING GIFT ITEM: $item");
    if (!_items.containsKey(item.giftID)) {
      _items[item.giftID] = [item];
    } else {
      _items[item.giftID]!.add(item);
      try {
        Gift gift = _gifts.singleWhere((gift) => gift.giftID == item.giftID);
        print(gift.title);
        gift.itemCount += 1;
        notifyListeners();
      } catch (err) {}
    }
  }

  Future<List<Gift>> load() async {
    if (!_loaded) {
      _loaded = true;
      _gifts = await GetIt.I<GiftService>().getGifts();
    }
    return _gifts;
  }

  Future<List<Item>> getItems(
    int gift_id, {
    required String token,
    String type: "all",
    bool force: false,
  }) async {
    if (!force && _items.containsKey(gift_id)) return _items[gift_id]!;

    _items[gift_id] = await GetIt.I<GiftService>().getGiftItems(
      gift_id,
      type: type,
      token: token,
    );

    try {
      Gift gift = _gifts.singleWhere((g) => g.giftID == gift_id, orElse: null);
      gift.itemCount = _items[gift_id]!.length;
    } catch (_) {}

    return _items[gift_id]!;
  }

  Future<ServerResponse> createGift({
    required String title,
    required int price,
    required String description,
    required String token,
  }) async {
    ServerResponse response = await locator<GiftService>().createGift(
      title: title,
      price: price,
      description: description,
      token: token,
    );
    if (response.ok) {
      Map<String, dynamic>? gift_json = response.data["gift"];
      if (gift_json != null) {
        Gift gift = Gift.fromJson(gift_json);
        addGift(gift);
      }
    }
    return response;
  }

  Future<ServerResponse> deleteGift(
    Gift gift, {
    required String token,
  }) async {
    ServerResponse response = await GetIt.I<GiftService>().deleteGift(
      gift.giftID,
      token: token,
    );
    if (response.ok) {
      _gifts.removeWhere((g) => g.giftID == gift.giftID);
      if (_items.containsKey(gift.giftID)) {
        _items.remove(gift.giftID);
      }
      notifyListeners();
    }
    return response;
  }

  Future<ServerResponse> deleteGiftItem(
    Item item, {
    required String token,
  }) async {
    ServerResponse response = await GetIt.I<GiftService>().deleteGiftItem(
      item.giftID,
      item.itemID,
      token: token,
    );
    if (response.ok) {
      try {
        Gift gift = _gifts.singleWhere((gift) => gift.giftID == item.giftID);
        gift.itemCount--;
      } catch (err) {}
      if (_items.containsKey(item.giftID)) {
        _items[item.giftID]!.removeWhere((i) => i.itemID == item.itemID);
      }
      notifyListeners();
    }

    return response;
  }

  Future<ServerResponse> createGiftItem(int gift_id,
      {required String value, required String token}) async {
    ServerResponse response = await GetIt.I<GiftService>().createGiftItem(
      gift_id,
      value,
      token: token,
    );
    if (response.ok) {
      Map<String, dynamic>? item_json = response.data["item"];
      if (item_json != null) {
        Item item = Item.fromJson(item_json);
        addGiftItem(item);
      }
    }
    return response;
  }
}
