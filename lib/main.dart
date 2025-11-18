import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:appliances_flutter/constants/constants.dart';
import 'package:appliances_flutter/views/entrypoint.dart';
import 'package:appliances_flutter/config/translations.dart';
import 'package:appliances_flutter/services/language_service.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appliances_flutter/firebase_options.dart';
import 'package:appliances_flutter/services/api_client.dart';

Widget defaultHome = MainScreen();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Kích hoạt Firebase App Check
  if (kReleaseMode) {
    // ✅ App phát hành (Play Integrity)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  } else {
    // ✅ App debug (Debug Token)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    );
  }

  await GetStorage.init();
  await _initMessaging();
  _watchAuthAndSyncFcm();
  runApp(const MyApp());
}

Future<void> _initMessaging() async {
  try {
    // For iOS: request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Get token (mobile). For web, push requires service worker + VAPID key; skip here.
    String? token;
    if (!kIsWeb) {
      token = await FirebaseMessaging.instance.getToken();
    } else {
      // Optional web push support if VAPID key provided at build time
      const vapidKey =
          String.fromEnvironment('WEB_PUSH_VAPID_KEY', defaultValue: '');
      if (vapidKey.isNotEmpty) {
        try {
          token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
        } catch (_) {}
      }
    }

    final box = GetStorage();
    if (token != null && token.isNotEmpty) {
      await box.write('fcm', token);
      // If user is logged in (token stored), send FCM token to backend
      final userJwt = box.read('token');
      if (userJwt != null && userJwt is String && userJwt.isNotEmpty) {
        try {
          await ApiClient.instance.post('/api/users/fcm-token', data: {
            'fcmToken': token,
          });
        } catch (_) {}
      }
    }

    // Update server when token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await box.write('fcm', newToken);
      final userJwt = box.read('token');
      if (userJwt != null && userJwt is String && userJwt.isNotEmpty) {
        try {
          await ApiClient.instance.post('/api/users/fcm-token', data: {
            'fcmToken': newToken,
          });
        } catch (_) {}
      }
    });
  } catch (e) {
    if (kDebugMode) {
      // ignore
    }
  }
}

void _watchAuthAndSyncFcm() {
  final box = GetStorage();
  box.listenKey('token', (value) async {
    if (value is String && value.isNotEmpty) {
      final fcm = box.read('fcm');
      if (fcm is String && fcm.isNotEmpty) {
        try {
          await ApiClient.instance.post('/api/users/fcm-token', data: {
            'fcmToken': fcm,
          });
        } catch (_) {}
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();

    return ScreenUtilInit(
      designSize: const Size(375, 825),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Future App',
          translations: AppTranslations(),
          locale: Locale(languageService.getCurrentLanguage()),
          fallbackLocale: const Locale('vi'),
          theme: ThemeData(
            scaffoldBackgroundColor: kOffWhite,
            iconTheme: const IconThemeData(color: kDark),
            primarySwatch: Colors.grey,
          ),
          home: defaultHome,
        );
      },
    );
  }
}
