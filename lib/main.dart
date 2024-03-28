import 'dart:io';

import 'package:booking/constants/style.dart';
import 'package:booking/services/my_http_overrides.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import 'ui/history/orders_history_screen.dart';
import 'ui/main_screen.dart';
import 'ui/profile/profile_login_screen.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/widgets/background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// Initializing the AppMetrica SDK.
    // await AppMetrica.activate(const AppMetricaConfig("7ec5f770-9461-4946-ae76-cc41601c8820"));
    HttpOverrides.global = MyHttpOverrides();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MainApp();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Сервис Заказа Такси',
      theme: ThemeData(
          primaryColor: Colors.white,
          textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: mainColor),
          )),
      initialRoute: '/splash',
      routes: {
        '/main': (context) => const MainScreen(),
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const ProfileLoginScreen(background: Background()),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/history':
            return PageTransition(child: const OrdersHistoryScreen(), type: PageTransitionType.fade, duration: const Duration(seconds: 1));
          default:
            return null;
        }
      },
    );
  }
}
