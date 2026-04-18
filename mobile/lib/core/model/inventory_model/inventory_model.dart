class InventoryModel {
  String? sku;
  String? name;
  String? category;
  num? quantity;
  int? minStock;
  num? price;
  String? location;
  int? supplierId;
  int? id;
  int? warehouseId;

  InventoryModel({
    this.sku,
    this.name,
    this.category,
    this.quantity,
    this.minStock,
    this.price,
    this.location,
    this.supplierId,
    this.id,
    this.warehouseId,
  });

  InventoryModel.fromJson(Map<String, dynamic> json) {
    sku = json['sku'];
    name = json['name'];
    category = json['category'];
    quantity = json['quantity'];
    minStock = json['min_stock'];
    price = json['price'];
    location = json['location'];
    supplierId = json['supplier_id'];
    id = json['id'];
    warehouseId = json['warehouse_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sku'] = sku;
    data['name'] = name;
    data['category'] = category;
    data['quantity'] = quantity;
    data['min_stock'] = minStock;
    data['price'] = price;
    data['location'] = location;
    data['supplier_id'] = supplierId;
    data['id'] = id;
    data['warehouse_id'] = warehouseId;
    return data;
  }
}
