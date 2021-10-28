import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:surveyplatform/data/network.dart';
import 'package:surveyplatform/data/response.dart';
import 'package:surveyplatform/data/states/auth_state.dart';
import 'package:surveyplatform/models/gift.dart';

class GiftService {
  static String serverPath = "/gifts/";

  Future<List<Item>> getUserClaimed({required String token}) async {
    ServerResponse response = await sendServerRequestAuthenticated(
      "$serverPath\items/claims",
      RequestType.Get,
      token: token,
    );
    List<dynamic> result = (response.data["items"] ?? []);

    List<Map<String, dynamic>> parsed = result
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
    return parsed.map<Item>((item) => Item.fromJson(item)).toList();
  }

  Future<List<Gift>> getGifts() async {
    ServerResponse response =
        await sendServerRequest(serverPath, RequestType.Get);
    List<dynamic> result = (response.data["gifts"] ?? []);

    List<Map<String, dynamic>> parsed = result
        .map(
          (gift) => Map<String, dynamic>.from(gift),
        )
        .toList();
    return parsed.map<Gift>((gift) => Gift.fromJson(gift)).toList();
  }

  Future<List<Item>> getGiftItems(
    int gift_id, {
    required String token,
    String type: "all",
  }) async {
    ServerResponse response = await sendServerRequestAuthenticated(
      "$serverPath/$gift_id/items",
      RequestType.Get,
      queryParams: {
        "type": type,
      },
      token: token,
    );
    List<dynamic> result = (response.data["items"] ?? []);

    List<Map<String, dynamic>> parsed = result
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
    return parsed.map<Item>((item) => Item.fromJson(item)).toList();
  }

  Future<ServerResponse> createGift({
    required String title,
    required int price,
    required String description,
    required String token,
  }) async {
    return await sendServerRequestAuthenticated(
      "$serverPath/",
      RequestType.Post,
      token: token,
      data: jsonEncode({
        "price": price,
        "title": title,
        "description": description,
      }),
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<ServerResponse> deleteGift(
    int gift_id, {
    required String token,
  }) async {
    return await sendServerRequestAuthenticated(
      "$serverPath/$gift_id",
      RequestType.Delete,
      token: token,
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<ServerResponse> createGiftItem(int gift_id, String value,
      {required String token}) async {
    return await sendServerRequestAuthenticated(
      "$serverPath/$gift_id/items",
      RequestType.Post,
      token: token,
      data: jsonEncode({
        "value": value,
      }),
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<ServerResponse> deleteGiftItem(int gift_id, int item_id,
      {required String token}) async {
    return await sendServerRequestAuthenticated(
      "$serverPath/$gift_id/items/$item_id",
      RequestType.Delete,
      token: token,
      headers: {"Content-Type": "application/json"},
    );
  }

  // Claims
  Future<ServerResponse> claimAnyGiftItem(
    Gift gift, {
    required String token,
  }) async {
    return await sendServerRequestAuthenticated(
      '/gifts/${gift.giftID}/items/claims',
      RequestType.Post,
      token: token,
    );
  }
}
