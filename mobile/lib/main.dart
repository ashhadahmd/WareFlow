import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const WareHouseManagementSystem());
}

class WareHouseManagementSystem extends StatelessWidget {
  const WareHouseManagementSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          initialRoute: GetAppStorage.checkUserLogin(),
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              // Ager user ne apne phone per font ka size change kiya huwa hai toh wooh app may change nhi hoga.
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
        );
      },
    );
  }
}
