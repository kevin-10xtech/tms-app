import 'package:get/get.dart';
import 'package:tmsapp/routes/app_routes.dart';
import 'package:tmsapp/view/home_screen.dart';
import 'package:tmsapp/view/splash_screen.dart';

class AppPages {
  static const initial = AppRoutes.splashScreen;

  static final routes = [
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.homeScreen, page: () => const HomeScreen()),
  ];
}
