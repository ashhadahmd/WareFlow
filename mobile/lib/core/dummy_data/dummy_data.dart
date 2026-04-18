import 'package:warehouse_management_system/core/model/inventory_model/inventory_model.dart';
import 'package:warehouse_management_system/core/model/orders_model/orders_model.dart';
import 'package:warehouse_management_system/core/model/supplier_model/supplier_model.dart';

class DummyData {
  List<SupplierModel> dummySuppliers = [
    SupplierModel(
      id: 1,
      name: "TechLogix Pakistan",
      contactName: "Arsalan Ahmed",
      email: "info@techlogix.pk",
      phone: 03001234567,
      address: "Gulshan-e-Iqbal, Karachi",
      status: "Active",
      rating: 5,
      warehouseId: 50,
    ),
    SupplierModel(
      id: 2,
      name: "Ali Electronics",
      contactName: "Ali Raza",
      email: "ali.elec@gmail.com",
      phone: 03219876543,
      address: "Hafeez Center, Lahore",
      status: "Inactive",
      rating: 3,
      warehouseId: 50,
    ),
  ];

  List<InventoryModel> dummyInventory = [
    InventoryModel(
      id: 101, // Product ID
      sku: "IPH-15-PRO",
      name: "iPhone 15 Pro",
      category: "Mobile",
      quantity: 45,
      minStock: 10,
      price: 350000,
      location: "Aisle 4, Shelf B",
      supplierId: 1, // 👈 Linked with TechLogix
      warehouseId: 50,
    ),
    InventoryModel(
      id: 102,
      sku: "LAP-DELL-XPS",
      name: "Dell XPS 13",
      category: "Laptops",
      quantity: 5, // 👈 Low Stock Alert logic test karne ke liye
      minStock: 8,
      price: 280000,
      location: "Aisle 1, Shelf A",
      supplierId: 1, // 👈 Linked with TechLogix
      warehouseId: 50,
    ),
    InventoryModel(
      id: 103,
      sku: "CAB-USB-C",
      name: "USB-C Fast Cable",
      category: "Accessories",
      quantity: 150,
      minStock: 20,
      price: 1500,
      location: "Aisle 10, Bin 5",
      supplierId: 2, // 👈 Linked with Ali Electronics
      warehouseId: 50,
    ),
  ];

  List<OrderModel> dummyOrders = [
    // Example 1: Inbound Order (Maal aa raha hai)
    OrderModel(
      id: 5001,
      orderNumber: "ORD-2024-001",
      orderType: "Inbound", // 👈 Type Check
      status: "Completed",
      orderDate: "2024-03-20",
      supplierId: 1,
      totalValue: 700000,
      items: [OrderItem(productId: 101, quantity: 2, priceAtOrder: 350000)],
      warehouseId: 50,
      notes: "New stock for iPhone",
    ),

    // Example 2: Outbound Order (Maal ja raha hai)
    OrderModel(
      id: 5002,
      orderNumber: "ORD-2024-002",
      orderType: "Outbound", // 👈 Type Check
      status: "Pending",
      orderDate: "2024-03-24",
      supplierId: 1,
      totalValue: 3000,
      items: [OrderItem(productId: 103, quantity: 2, priceAtOrder: 1500)],
      warehouseId: 50,
      notes: "Customer delivery",
    ),
  ];
}
