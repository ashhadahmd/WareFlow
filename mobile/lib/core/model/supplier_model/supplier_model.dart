class SupplierModel {
  String? name;
  String? contactName;
  String? email;
  int? phone;
  String? address;
  String? status;
  int? rating;
  int? id;
  int? warehouseId;

  SupplierModel({
    this.name,
    this.contactName,
    this.email,
    this.phone,
    this.address,
    this.status,
    this.rating,
    this.id,
    this.warehouseId,
  });

  SupplierModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    contactName = json['contact_name']?.toString();
    email = json['email']?.toString();
    phone = int.tryParse(json['phone'].toString());
    address = json['address']?.toString();
    status = json['status']?.toString();
    rating = double.tryParse(json['rating'].toString())?.toInt();
    id = int.tryParse(json['id'].toString());
    warehouseId = int.tryParse(json['warehouse_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['contact_name'] = contactName;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['status'] = status;
    data['rating'] = rating;
    data['id'] = id;
    data['warehouse_id'] = warehouseId;
    return data;
  }
}
