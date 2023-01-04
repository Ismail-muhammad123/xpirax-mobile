import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/pages/inventory/newInventory.dart';
import 'package:xpirax/providers/web_database_providers.dart';

import '../../providers/database/dataBase_manager.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryProvider inventory = InventoryProvider();
  final TextEditingController _searchController = TextEditingController();

  Future<List<Inventory>> _searchInventory() async => await context
      .read<LocalDatabaseHandler>()
      .getItemsFromInventory()
      .then(
        (value) => value
            .where((element) => element.name.contains(_searchController.text))
            .toList(),
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  var dateValue = 'Today';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: 'reload',
          //   tooltip: 'Reload inventory items',
          //   elevation: 20.0,
          //   onPressed: () => setState(() {}),
          //   child: const Icon(
          //     Icons.replay_outlined,
          //     size: 40.0,
          //   ),
          // ),
          // Padding(padding: EdgeInsets.all(12)),
          FloatingActionButton(
            heroTag: 'new',
            tooltip: 'Add new item to inventory',
            elevation: 20.0,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewInventoryPage(),
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 40.0,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Inventory'.toUpperCase()),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            Container(
              color: Colors.tealAccent,
              padding: const EdgeInsets.all(10.0),
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search (Item Name)',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                  ),
                  MaterialButton(
                    height: 55,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: SizedBox(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.teal,
                                  width: double.maxFinite,
                                  height: 50.0,
                                  alignment: Alignment.center,
                                  child: const Text('Search results'),
                                ),
                                FutureBuilder<List<Inventory>>(
                                  future: _searchInventory(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState !=
                                        ConnectionState.waiting) {
                                      return Container(
                                        color:
                                            Colors.tealAccent.withOpacity(0.3),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    if (snapshot.data!.isEmpty ||
                                        snapshot.data == null) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        color:
                                            Colors.tealAccent.withOpacity(0.3),
                                        child: const Center(
                                          child: Text('No Item Found'),
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      width: double.maxFinite,
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        child: InventoryTable(
                                          data: snapshot.data!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    color: Colors.teal,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        MediaQuery.of(context).size.width > 400
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FutureBuilder<List<Inventory>?>(
                  future: context
                      .watch<LocalDatabaseHandler>()
                      .getItemsFromInventory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(
                        height: 500,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  'Your Inventory is Empty!',
                                  style: TextStyle(fontSize: 18.0),
                                  softWrap: true,
                                ),
                                MaterialButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewInventoryPage(),
                                    ),
                                  ),
                                  color: Colors.teal,
                                  child: Text("Add"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return InventoryTable(
                      data: snapshot.data!,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryTable extends StatefulWidget {
  final List<Inventory> data;
  const InventoryTable({Key? key, required this.data}) : super(key: key);

  @override
  State<InventoryTable> createState() => _InventoryTableState();
}

class _InventoryTableState extends State<InventoryTable> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 40.0,
        sortColumnIndex: 1,
        headingTextStyle: TextStyle(
          color: Colors.teal,
        ),
        columns: const [
          DataColumn(
            label: Text('Name'),
          ),
          DataColumn(
            label: Text('Price'),
          ),
          DataColumn(
            label: Text('Available'),
          ),
          DataColumn(
            label: Text('Actions'),
          ),
        ],
        rows: List.generate(
          data.length,
          (index) => DataRow(
            cells: [
              DataCell(
                Text(
                  data[index].name,
                  textAlign: TextAlign.center,
                ),
              ),
              DataCell(
                Text(
                  NumberFormat('###,###,###').format(data[index].price),
                  textAlign: TextAlign.center,
                ),
              ),
              DataCell(
                Text(
                  NumberFormat('###,###,###')
                      .format(data[index].availableQuantity),
                  textAlign: TextAlign.center,
                ),
              ),
              DataCell(
                PopupMenuButton(
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<int>(value: 0, child: Text('Edit')),
                    ];
                  },
                  onSelected: (item) async {
                    switch (item) {
                      case 0:
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewInventoryPage(
                              data: data[index],
                            ),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }
}
