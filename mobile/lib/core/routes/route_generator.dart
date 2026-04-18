import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/features/bottom_navigation/bottom_navigation.dart';
import 'package:warehouse_management_system/features/create_order/create_order.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard.dart';
import 'package:warehouse_management_system/features/inventory/show_inventory.dart';
import 'package:warehouse_management_system/features/product_features/add_product.dart';
import 'package:warehouse_management_system/features/product_features/update_product.dart';
import 'package:warehouse_management_system/features/start_screen/login_screen/login_screen.dart';
import 'package:warehouse_management_system/features/start_screen/select_warehouse/select_warehouse.dart';
import 'package:warehouse_management_system/features/start_screen/sign_up_screen/sign_up_screen.dart';
import 'package:warehouse_management_system/features/supplier_features/add_supplier.dart';
import 'package:warehouse_management_system/features/supplier_features/update_supplier.dart';
import 'package:warehouse_management_system/features/suppliers/show_supplier_detail.dart';
// ...

class RouteGenerator {
  // 1. HELPER METHOD: Ye method baar baar animation likhne se bachayega
  static Route<dynamic> _animatedRoute(Widget page, RouteSettings settings) {
    return PageTransition(
      child: page,
      type: PageTransitionType
          .rightToLeft, // Sab screens par right-to-left animation
      duration: const Duration(milliseconds: 300),
      settings: settings,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.loginScreen:
        return _animatedRoute(LoginScreen(), settings);

      case AppRoutes.signUpScreen:
        return _animatedRoute(SignUpScreen(), settings);

      case AppRoutes.selectWarehouseScreen:
        return _animatedRoute(SelectWarehouse(), settings);

      case AppRoutes.bottomNavigationScreen:
        return _animatedRoute(BottomNavigation(), settings);

      case AppRoutes.addProductScreen:
        return _animatedRoute(AddProduct(), settings);

      case AppRoutes.updateProductScreen:
        return _animatedRoute(UpdateProduct(), settings);

      case AppRoutes.updateSupplierScreen:
        return _animatedRoute(UpdateSupplier(), settings);

      case AppRoutes.addSupplierScreen:
        return _animatedRoute(AddSupplier(), settings);

      case AppRoutes.dashboardScreen:
        return _animatedRoute(Dashboard(), settings);

      case AppRoutes.createOrderScreen:
        return _animatedRoute(CreateOrder(), settings);

      case AppRoutes.showInventoryScreen:
        return _animatedRoute(ShowInventory(), settings);

      case AppRoutes.showSupplierScreen:
        return _animatedRoute(ShowSupplier(), settings);

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Error: Route not found')),
          ),
        );
    }
  }
}
