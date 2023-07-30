import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xpirax/pages/splashScreen/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
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
      title: 'Xpirax Book-Keeping App',
      theme: ThemeData(
        primaryColor: Colors.tealAccent,
        canvasColor: Colors.white,
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}
