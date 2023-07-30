import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpirax/data/data.dart';
import 'package:xpirax/filters.dart';
import 'package:xpirax/pages/sells/transaction_form.dart';
import 'package:xpirax/pages/sells/sellsDetails.dart';

class SellsPage extends StatefulWidget {
  const SellsPage({Key? key}) : super(key: key);

  @override
  State<SellsPage> createState() => _SellsPageState();
}

class _SellsPageState extends State<SellsPage> {
  final TextEditingController _searchController = TextEditingController();

  String searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTimeRange _sortDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  _select(String val) async {
    switch (val.toLowerCase()) {
      case 'all':
        setState(() {
          _sortDateRange =
              DateTimeRange(start: DateTime(2022), end: DateTime.now());
        });
        break;
      case 'today':
        setState(() {
          _sortDateRange =
              DateTimeRange(start: DateTime.now(), end: DateTime.now());
        });
        break;
      case 'select':
        var start = await showDatePicker(
          context: context,
          helpText: "Select Start Date",
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2040),
          currentDate: DateTime.now(),
        );
        var end = await showDatePicker(
          context: context,
          helpText: "Select End Date",
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2040),
          currentDate: DateTime.now(),
        );

        if (start != null && end != null) {
          setState(
            () => _sortDateRange = DateTimeRange(start: start, end: end),
          );
        }

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.calendar_month),
            onSelected: _select,
            padding: EdgeInsets.zero,
            // initialValue: choices[_selection],
            itemBuilder: (BuildContext context) {
              return ['all', 'today', 'select'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice.toUpperCase()),
                );
              }).toList();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SellsForm(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.tealAccent,
            padding: const EdgeInsets.all(10.0),
            width: double.maxFinite,
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onChanged: (val) => setState(() {
                          searchText = val;
                        }),
                        decoration: const InputDecoration(
                          hintText: 'Search (ID)',
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
                        searchText = "";
                        _searchController.clear();
                      }),
                      color: Colors.teal,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.tealAccent,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(
                    height: 500,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'No Transactions yet.',
                          style: TextStyle(fontSize: 18.0),
                          softWrap: true,
                        ),
                      ),
                    ),
                  );
                }
                return SellsRecord(
                  data: snapshot.data!.docs
                      .map((e) {
                        var t = TransactionData.fromJson(e.data());
                        t.id = e.id;
                        return t;
                      })
                      .where((e) => passedDateFilter(e.time, _sortDateRange))
                      .where(
                        (element) =>
                            element.id!
                                .toLowerCase()
                                .contains(searchText.trim().toLowerCase()) ||
                            element.serialNumber.toString() ==
                                searchText.trim(),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SellsRecord extends StatefulWidget {
  final List<TransactionData> data;
  const SellsRecord({Key? key, required this.data}) : super(key: key);

  @override
  State<SellsRecord> createState() => _SellsRecordState();
}

class _SellsRecordState extends State<SellsRecord> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        var e = widget.data[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: ListTile(
              title: Text(
                  "#${e.serialNumber != null ? e.serialNumber.toString().padLeft(7, "0") : e.id}"),
              subtitle: Text(
                DateFormat('yMMMMEEEEd').add_jm().format(
                      e.time.toDate(),
                    ),
              ),
              trailing:
                  Text("NGN ${NumberFormat('###,###,###').format(e.amount)}"),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SellsDetails(
                    transaction: e,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
