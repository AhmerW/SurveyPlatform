class Gift {
  String title, description;
  int price;
  int itemCount;
  final int giftID;

  Gift(this.giftID,
      {required this.title,
      required this.price,
      required this.description,
      this.itemCount: 0});

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      json["gift_id"],
      title: json["title"],
      price: json["price"],
      description: json["description"],
      itemCount: json["item_count"] ?? 0,
    );
  }
}

class Item {
  final String value;
  final int giftID;
  final bool claimed;
  final int? claimedBy;

  Item(
    this.value, {
    required this.giftID,
    required this.claimed,
    this.claimedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json["value"],
        giftID: json["gift_id"],
        claimed: json["claimed"],
        claimedBy: json["claimed_by"]);
  }
}
