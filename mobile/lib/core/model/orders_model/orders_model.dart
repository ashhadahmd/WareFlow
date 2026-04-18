class OrderModel {
  String? orderType;
  int? supplierId;
  num? totalValue;
  String? status;
  String? notes;
  int? id;
  String? orderNumber;
  String? orderDate;
  int? warehouseId;
  List<OrderItem>? items;

  OrderModel({
    this.orderType,
    this.supplierId,
    this.totalValue,
    this.status,
    this.notes,
    this.id,
    this.orderNumber,
    this.orderDate,
    this.warehouseId,
    this.items,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    orderType = json['order_type'];
    supplierId = json['supplier_id'];
    totalValue = json['total_value'];
    status = json['status'];
    notes = json['notes'];
    id = json['id'];
    orderNumber = json['order_number'];
    orderDate = json['order_date'];
    warehouseId = json['warehouse_id'];
    if (json['items'] != null) {
      items = <OrderItem>[];
      json['items'].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_type'] = orderType;
    data['supplier_id'] = supplierId;
    data['total_value'] = totalValue;
    data['status'] = status;
    data['notes'] = notes;
    data['id'] = id;
    data['order_number'] = orderNumber;
    data['order_date'] = orderDate;
    data['warehouse_id'] = warehouseId;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderItem {
  num? productId;
  num? quantity;
  num? priceAtOrder;

  OrderItem({this.productId, this.quantity, this.priceAtOrder});

  OrderItem.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    quantity = json['quantity'];
    priceAtOrder = json['price_at_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['price_at_order'] = priceAtOrder;
    return data;
  }
}
