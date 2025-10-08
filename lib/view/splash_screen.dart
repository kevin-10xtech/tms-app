import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmsapp/routes/app_routes.dart';
import 'package:tmsapp/utils/app_images.dart';
import 'package:tmsapp/utils/math_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    initRoute();
  }

  void initRoute() async {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAndToNamed(AppRoutes.homeScreen);
      // if (box.read(AppStorageKeys.token) == null) {
      //   if (Platform.isIOS) {
      //     Get.offAndToNamed(AppRoutes.mainDashboard);
      //   } else {
      //     Get.offAndToNamed(AppRoutes.loginScreen);
      //   }
      // } else {
      //   authController.handleVerifyTokenBeforeGamePlay();
      //   authController.handleVerifyToken();
      //   // Get.offAndToNamed(AppRoutes.mainDashboard);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: getSizeWidth(context, 3)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                AppImages.appLogo,
                height: getSizeHeight(context, 40),
              ),
            ),
            // SizedBox(height: getSizeHeight(context, 1.5)),
            // baseText(
            //   'Mahayoga (Siddhayoga)',
            //   fontSize: 24,
            //   fontWeight: FontWeight.w500,
            // ),
            // SizedBox(height: getSizeHeight(context, 0.5)),
            // baseText(
            //   'Self-realization through Joyous, Serene and Divine experiences',
            //   fontSize: 20,
            //   color: AppColors.grey,
            //   fontWeight: FontWeight.w500,
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}
