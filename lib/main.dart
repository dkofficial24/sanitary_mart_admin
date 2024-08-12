import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart_admin/auth/provider/auth_provider.dart';
import 'package:sanitary_mart_admin/auth/screen/login_screen.dart';
import 'package:sanitary_mart_admin/brand/provider/brand_provider.dart';
import 'package:sanitary_mart_admin/brand/service/brand_firebase_service.dart';
import 'package:sanitary_mart_admin/category/provider/category_provider.dart';
import 'package:sanitary_mart_admin/category/service/category_firebase_service.dart';
import 'package:sanitary_mart_admin/core/constant/constant.dart';
import 'package:sanitary_mart_admin/customer/provider/customer_provider.dart';
import 'package:sanitary_mart_admin/customer/service/customer_firebase_service.dart';
import 'package:sanitary_mart_admin/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart_admin/firebase_options.dart';
import 'package:sanitary_mart_admin/incentive_points/service/incentive_provider_service.dart';
import 'package:sanitary_mart_admin/notification/provider/notification_provider.dart';
import 'package:sanitary_mart_admin/notification/service/local_notification_service.dart';
import 'package:sanitary_mart_admin/notification/service/notification_service.dart';
import 'package:sanitary_mart_admin/order/provider/order_provider.dart';
import 'package:sanitary_mart_admin/order/service/order_firebase_service.dart';
import 'package:sanitary_mart_admin/payment/provider/payment_info_provider.dart';
import 'package:sanitary_mart_admin/product/provider/product_provider.dart';
import 'package:sanitary_mart_admin/product/service/product_service.dart';
import 'package:sanitary_mart_admin/util/storage_helper.dart';

import 'payment/service/payment_firebase_service.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.initialize();
  await initFirebase();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final notificationService = NotificationService();
  notificationService.listenForNewNotifications();

  runApp(const VendorAdminApp());
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class VendorAdminApp extends StatelessWidget {
  const VendorAdminApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final productFirebaseService = ProductService();
    final categoryFirebaseService = CategoryFirebaseService();
    final brandFirebaseService = BrandFirebaseService();
    Get.put(OrderFirebaseService());
    Get.put(CustomerFirebaseService());
    Get.put(PaymentFirebaseService());
    Get.put(IncentivePointService());
    Get.put(productFirebaseService);
    StorageHelper storageHelper = StorageHelper();

    final authProvider = AuthenticationProvider(
      storageHelper,
    );
    authProvider.loadLoggedStatus();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(
            productService: productFirebaseService,
            categoryFirebaseService: categoryFirebaseService,
            brandFirebaseService: brandFirebaseService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(categoryFirebaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => BrandProvider(brandFirebaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentInfoProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationService(),
          ),
        )
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (context, provider, child) {
          return GetMaterialApp(
            title: AppText.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: AppColor.primaryColor,
              primaryColor: AppColor.primaryColor,
            ),
            navigatorObservers: [observer],
            home: true ? const DashboardScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}
