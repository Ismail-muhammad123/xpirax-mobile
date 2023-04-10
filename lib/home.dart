import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:xpirax/data/data.dart';
import 'package:xpirax/pages/dashboard/dashboard.dart';
import 'package:xpirax/pages/inventory/inventory.dart';
import 'package:xpirax/pages/inventory/newInventory.dart';
import 'package:xpirax/pages/login/loginPage.dart';
import 'package:xpirax/pages/sells/transaction_form.dart';
import 'package:xpirax/pages/sells/sellsRecord.dart';
import 'package:xpirax/pages/settings/settings.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _pages = [
    Dashboard(),
    InventoryPage(),
    SellsPage(),
    SettingsPage(),
  ];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentPage,
              onTap: (value) => setState(() => _currentPage = value),
              selectedItemColor: Colors.teal,
              unselectedItemColor: Color.fromRGBO(0, 0, 0, 1),
              showUnselectedLabels: true,
              selectedFontSize: 12.0,
              unselectedFontSize: 12.0,
              enableFeedback: true,
              type: BottomNavigationBarType.fixed,
              iconSize: 30,
              elevation: 8.0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.calculator),
                  label: "Inventory",
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.cartShopping),
                  label: "Transactions",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
            body: _pages[_currentPage],
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
