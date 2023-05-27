import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpirax/data/data.dart';
import 'package:xpirax/pages/sells/transaction_form.dart';
import 'package:xpirax/pages/sells/sellsDetails.dart';

class SellsPage extends StatefulWidget {
  const SellsPage({Key? key}) : super(key: key);

  @override
  State<SellsPage> createState() => _SellsPageState();
}

class _SellsPageState extends State<SellsPage> {
  final TextEditingController _searchController = TextEditingController();

  Future<List<TransactionData>> _searchTransactions() async {
    return await FirebaseFirestore.instance
        .collection('transactions')
        .get()
        .then(
          (value) => value.docs.map(
            (e) => TransactionData(
              id: e.id,
              customerName: e.data()['customerName'],
              customerAddress: e.data()['customerAddress'],
              customerPhoneNumber: e.data()['customerPhoneNumber'],
              customerEmail: e.data()['customerEmail'],
              amount: e.data()['amount'],
              amountPaid: e.data()['amountPaid'],
              discount: e.data()['discount'],
              balance: e.data()['balance'],
              time: e.data()['time'],
              attendant: e.data()['attendant'],
            ),
          ),
        )
        .then(
          (value) => value
              .where(
                (element) => element.customerName.contains(
                  _searchController.text.trim(),
                ),
              )
              .toList(),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SellsForm(),
          ),
        ),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Transactions Record'),
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
                    const Flexible(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search (Customer Name)',
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
                    MaterialButton(
                      height: 55,
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Flexible(
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
                                  FutureBuilder<List<TransactionData>>(
                                    future: _searchTransactions(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text("No Records Found"),
                                          ),
                                        );
                                      }

                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9
                                                : double.maxFinite,
                                        child: Card(
                                          elevation: 5.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Center(
                                                child: SellsRecord(
                                                  data: snapshot.data!,
                                                ),
                                              ),
                                            ),
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
                        children: const [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                          ),
                          Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
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
                        .map(
                          (e) => TransactionData(
                            id: e.id,
                            customerName: e.data()['customerName'],
                            customerAddress: e.data()['customerAdress'],
                            customerPhoneNumber:
                                e.data()['customerPhoneNumber'],
                            customerEmail: e.data()['customerEmail'],
                            amount: e.data()['amount'],
                            amountPaid: e.data()['amountPaid'],
                            discount: e.data()['discount'],
                            balance: e.data()['balance'],
                            time: e.data()['time'],
                            attendant: e.data()['attendant'],
                          ),
                        )
                        .toList(),
                  );
                },
              ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width - 100),
        child: DataTable(
          columnSpacing: 16.0,
          headingTextStyle: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
          columns: const [
            DataColumn(label: Text('Customer Name')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: widget.data
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(Text(
                      e.customerName,
                      textAlign: TextAlign.center,
                    )),
                    DataCell(Text(
                      e.amount.toString(),
                      textAlign: TextAlign.center,
                    )),
                    DataCell(Text(
                      DateFormat("d/M/y").format(
                        e.time.toDate(),
                      ),
                      textAlign: TextAlign.center,
                    )),
                    DataCell(
                      MaterialButton(
                        color: Colors.teal,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SellsDetails(
                              transaction: e,
                            ),
                          ),
                        ),
                        child: const Text("VIEW"),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
