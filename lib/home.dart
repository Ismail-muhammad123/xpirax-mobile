import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/pages/dashboard/dashboard.dart';
import 'package:xpirax/pages/inventory/inventory.dart';
import 'package:xpirax/pages/inventory/newInventory.dart';
import 'package:xpirax/pages/login/loginPage.dart';
import 'package:xpirax/pages/sells/newSells.dart';
import 'package:xpirax/pages/sells/sellsRecord.dart';
import 'package:xpirax/pages/settings/settings.dart';
import 'package:xpirax/providers/web_database_providers.dart';
import 'package:xpirax/widgets/menuTile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    const DashBoard(),
    const InventoryPage(),
    const SellsPage(),
    const SettingsPage(),
  ];
  int? _currentPage;

  @override
  void initState() {
    _currentPage = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xpirax POS".toUpperCase()),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Colors.teal,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.teal,
                width: double.maxFinite,
                height: 56,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "XPIRAX POS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 5.0,
              ),
              GestureDetector(
                onTap: () => changeCurrentPage(index: 0),
                child: MenuTile(
                  title: "Dashboard",
                  icon: Icons.add_chart_sharp,
                  current: _currentPage == 0,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => changeCurrentPage(index: 1),
                child: MenuTile(
                  title: "Inventory",
                  icon: Icons.inventory,
                  trailing: IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewInventoryPage(),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  current: _currentPage == 1,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => changeCurrentPage(index: 2),
                child: MenuTile(
                  title: "Transactions",
                  icon: Icons.attach_money_sharp,
                  current: _currentPage == 2,
                  color: Colors.white,
                  trailing: IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SellsForm(),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SellsForm(),
                  ),
                ),
                child: MenuTile(
                  title: "New Transaction",
                  icon: Icons.add,
                  current: false,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => changeCurrentPage(index: 3),
                child: MenuTile(
                  title: "Profile",
                  icon: Icons.person,
                  current: _currentPage == 3,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await context
                      .read<Authentication>()
                      .logout()
                      .then(
                        (value) => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                      )
                      .then(
                        (value) => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        ),
                      );
                },
                child: MenuTile(
                  title: "Logout",
                  icon: Icons.logout,
                  current: _currentPage == 3,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_currentPage!],
    );
  }

  void changeCurrentPage({int index = 0}) {
    setState(() => _currentPage = index);
    Navigator.of(context).pop();
  }
}
