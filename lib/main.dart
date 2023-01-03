import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/providers/database/dataBase_manager.dart';
import 'package:xpirax/pages/splashScreen/splashScreen.dart';
import 'package:xpirax/providers/web_database_providers.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocalDatabaseHandler(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => TransactionsProvider(),
        // ),
        ChangeNotifierProvider(
          create: (_) => Authentication(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyCustomeScrollBehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomeScrollBehaviour(),
      debugShowCheckedModeBanner: false,
      title: 'Xpirax Accounting App',
      theme: ThemeData(
        primaryColor: Colors.tealAccent,
        canvasColor: Colors.white,
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}
