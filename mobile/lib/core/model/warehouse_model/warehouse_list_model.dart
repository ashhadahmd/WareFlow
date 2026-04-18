class WarehouseListModel {
  String? name;
  int? id;
  String? createdAt;

  WarehouseListModel({this.name, this.id, this.createdAt});

  WarehouseListModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['created_at'] = createdAt;
    return data;
  }

  String? get formattedDate {
    if (createdAt!.isEmpty) return "N/A";

    try {
      DateTime dt = DateTime.parse(
        createdAt!,
      ); // ISO string ko DateTime object banaya

      // Manually format: 12-04-2026
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString();

      return "$day-$month-$year";
    } catch (e) {
      return createdAt; // Agar error aaye toh raw string dikha do
    }
  }
}
