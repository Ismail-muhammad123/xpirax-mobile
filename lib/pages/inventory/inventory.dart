import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpirax/data/data.dart';
import 'package:xpirax/pages/inventory/newInventory.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();

  var inventoryStream =
      FirebaseFirestore.instance.collection('inventory').snapshots();

  Future<List<InventoryData>> _searchInventory() async =>
      await FirebaseFirestore.instance
          .collection('inventory')
          .get()
          .then(
            (value) => value.docs.map(
              (e) => InventoryData.fromMap(e.data()),
            ),
          )
          .then(
            (value) => value
                .where(
                    (element) => element.name.contains(_searchController.text))
                .toList(),
          );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  var dateValue = 'Today';
  String _searchtext = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                      onChanged: (val) => setState(() {
                        _searchtext = val;
                      }),
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
                    height: 50,
                    onPressed: () => setState(() {
                      _searchtext = "";
                      _searchController.clear();
                    }),
                    color: Colors.teal,
                    child: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: inventoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                    data: snapshot.data!.docs
                        .map(
                          (e) {
                            var i = InventoryData.fromMap(e.data());
                            i.id = e.id;
                            return i;
                          },
                        )
                        .where(
                          (element) => element.name.toLowerCase().contains(
                                _searchtext.trim().toLowerCase(),
                              ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryTable extends StatefulWidget {
  final List<InventoryData> data;
  const InventoryTable({Key? key, required this.data}) : super(key: key);

  @override
  State<InventoryTable> createState() => _InventoryTableState();
}

class _InventoryTableState extends State<InventoryTable> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return ListView.builder(
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
            title: Text(data[index].name),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Available Quantity: ${data[index].available_quantity}"),
                Text("Price: ${data[index].maxPrice}"),
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewInventoryPage(
                  data: data[index],
                ),
              ),
            ),
          ),
        ),
      ),
      itemCount: data.length,
    );
  }
}
