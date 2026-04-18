import 'package:get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';

class GetAppStorage {
  static final box = GetStorage();
  // user ka token
  static void getData(String? token) {
    box.write('user_login', token);
  }

  // yaha per read
  static String readData() {
    return box.read('user_login') ?? "";
  }

  // warehouse name

  static void saveWarehouseName(String name) {
    box.write('select_warehouse_name', name);
  }

  static String readWarehouseName() {
    return box.read('select_warehouse_name') ?? "";
  }

  // warehouse id
  static void getWarehouseID_Data(int warehouseID) {
    box.write('select_warehouse_id', warehouseID);
  }

  static int readWarehouseID_Data() {
    return box.read('select_warehouse_id') ?? 0;
  }

  // Direct app khulte hee bottomnaviagion per lejana user ko

  static String checkUserLogin() {
    String userToken = readData();
    int warehouseID = readWarehouseID_Data();

    // ager warehouse yaha per zero ky equal nhi huwa toh bottomnavigation per navigate krdo
    if (warehouseID != 0) {
      return AppRoutes.bottomNavigationScreen;
    } else if (userToken.isNotEmpty) {
      return AppRoutes.selectWarehouseScreen;
    } else {
      return AppRoutes.loginScreen;
    }
  }

  //Logout func

  static Future<void> clearAll() async {
    await box.erase();
  }
}
