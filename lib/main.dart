import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tmsapp/routes/app_pages.dart';
import 'package:tmsapp/routes/app_routes.dart';
import 'package:tmsapp/utils/app_constant_strings.dart';
import 'package:tmsapp/view/splash_screen.dart';

void main() async {
  ///
  WidgetsFlutterBinding.ensureInitialized();

  ///GetStorage
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstantStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        scaffoldBackgroundColor: Colors.white,
      ),
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
      unknownRoute: GetPage(
        name: AppRoutes.splashScreen,
        page: () => const SplashScreen(),
      ),
      // home: HomeScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            // data:
            //     MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
              boldText: Platform.isIOS ? true : null,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
