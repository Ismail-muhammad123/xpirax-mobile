import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/pages/splashScreen/splashScreen.dart';
import 'package:xpirax/providers/web_database_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setMinWindowSize(
      const Size(1200, 600),
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider(),
        ),
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
      title: 'Xpirax POS',
      theme: ThemeData(
        primaryColor: Colors.tealAccent,
        canvasColor: Colors.white,
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}
