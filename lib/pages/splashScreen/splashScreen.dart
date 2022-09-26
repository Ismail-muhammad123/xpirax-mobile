import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpirax/home.dart';
import 'package:xpirax/pages/dashboard/dashboard.dart';
import 'package:xpirax/pages/login/loginPage.dart';
import '../../providers/web_database_providers.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    context.watch<Authentication>().isLogedIn().then(
      (value) {
        value == true
            ? Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              )
            : Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              "Xpirax Point of Sales".toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Loading, Please wait..."),
            ),
          ],
        ),
      ),
    );
  }
}
