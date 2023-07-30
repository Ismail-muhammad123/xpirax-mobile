import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:xpirax/data/data.dart';
import 'package:xpirax/pages/sells/sellsDetails.dart';
import 'package:uuid/uuid.dart';

import 'package:provider/provider.dart';

class SellsForm extends StatefulWidget {
  final TransactionData? trx;
  final List<SoldItem>? transactionItems;
  const SellsForm({
    Key? key,
    this.trx,
    this.transactionItems,
  }) : super(key: key);

  @override
  State<SellsForm> createState() => _SellsFormState();
}

class _SellsFormState extends State<SellsForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('inventory').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return NewSellsPage(
              inventoryData: snapshot.data!.docs
                  .map((e) => InventoryData.fromMap(e.data()))
                  .where((element) => element.available_quantity > 0)
                  .toList(),
              transaction: widget.trx,
              items: widget.transactionItems,
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Card(
                elevation: 5.0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('You have no Item In your Inventory'),
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class NewSellsPage extends StatefulWidget {
  final List<InventoryData> inventoryData;
  final TransactionData? transaction;
  final List<SoldItem>? items;
  const NewSellsPage({
    Key? key,
    required this.inventoryData,
    this.transaction,
    this.items,
  }) : super(key: key);

  @override
  State<NewSellsPage> createState() => NewSellsPageState();
}

class NewSellsPageState extends State<NewSellsPage> {
  String itemName = '';
  double maxPrice = 0;
  double minPrice = 0;
  List<InventoryData> inventoryItems = [];
  List<SoldItem> addedItems = [];

  int transactionID = 0;

  _getEditabeItems() async {
    var items = await FirebaseFirestore.instance
        .collection('sales')
        .where('transactionUid', isEqualTo: widget.transaction!.id!)
        .get();
    setState(() {
      addedItems = items.docs.map((e) => SoldItem.fromJson(e.data())).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    inventoryItems.addAll(widget.inventoryData);

    if (inventoryItems.isNotEmpty) {
      itemName = inventoryItems.first.name;
      _priceController.text = inventoryItems.first.maxPrice.toString();
    }

    if (widget.transaction != null) {
      _editing = true;

      var trx = widget.transaction!;
      // _transactionID = trx!.id;

      _customerNameController.text = trx.customerName;
      _addressController.text = trx.customerAddress;
      _numberCOntroller.text = trx.customerPhoneNumber;
      _emailCOntroller.text = trx.customerEmail;
      _totalAmountController.text = trx.amount.toString();
      _amountPaidController.text = trx.amountPaid.toString();

      _balanceController.text = trx.balance.toString();
      totalAmount = trx.amount;

      _equivalentAmount.text = trx.amount.toString();

      _posController.text = trx.pos.toString();
      _transferController.text = trx.transfer.toString();
      _cashController.text = trx.cash.toString();
      _amountPaidController.text = trx.amountPaid.toString();
      addedItems.addAll(widget.items ?? []);

      _getEditabeItems();
    } else {
      _amountPaidController.text = "0";
      FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('time')
          .get()
          .then(
            (value) => setState(() =>
                transactionID = value.docs.last.data()['serial number'] ?? 0),
          );
    }
  }

  // input controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalAmountController =
      TextEditingController(text: "0");
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _equivalentAmount =
      TextEditingController(text: "0");
  final TextEditingController _amountPaidController =
      TextEditingController(text: "0");
  final TextEditingController _balanceController =
      TextEditingController(text: "0");
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _numberCOntroller = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailCOntroller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _posController = TextEditingController(text: "0");
  final TextEditingController _transferController =
      TextEditingController(text: "0");
  final TextEditingController _cashController =
      TextEditingController(text: "0");

  final uid = const Uuid();

  bool _editing = false;

  bool _processing = false;

  double totalAmount = 0;
  double payableamount = 0;
  String _searchText = "";

  _addItem() {
    if (_quantityController.text.isNotEmpty) {
      var selected =
          inventoryItems.where((element) => element.name == itemName).first;
      if (selected.available_quantity <
          double.parse(_quantityController.text.trim())) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.error),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
                Text("Alert"),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.blue,
                child: const Text("OK"),
              ),
            ],
            content: const Text(
              "The quantity selected for this item is greater that what is available in Stock!",
            ),
          ),
        );
        return;
      }
      if (double.parse(_priceController.text.trim()) < minPrice ||
          double.parse(_priceController.text.trim()) > maxPrice) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.error),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
                Text("Alert"),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.blue,
                child: const Text("OK"),
              ),
            ],
            content: const Text(
              "Invalid Price",
            ),
          ),
        );
        setState(() => _priceController.text = maxPrice.toString());
        return;
      }
      try {
        double price = double.parse(_priceController.text.trim());
        var obj = SoldItem(
          name: selected.name,
          quantity: double.parse(_quantityController.text),
          price: double.parse(_priceController.text.trim()),
          amount: price * double.parse(_quantityController.text.trim()),
          salesTime: Timestamp.now(),
        );

        if (addedItems.any((e) => e.name == obj.name)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text(
                  'Item is already added. You should edit the item instead.'),
              title: Text(
                'Error'.toUpperCase(),
                style: const TextStyle(color: Colors.red),
              ),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.blueAccent,
                  child: const Text('Okay'),
                )
              ],
            ),
          );
          return;
        }
        List<SoldItem> items = [];
        items.add(obj);

        var paid = _amountPaidController.text.isNotEmpty
            ? _amountPaidController.text
            : '0';

        setState(() {
          addedItems = addedItems + items;
          totalAmount =
              totalAmount + (price * double.parse(_quantityController.text));
          _equivalentAmount.text = totalAmount.toString();
          _quantityController.clear();
          _balanceController.text =
              (totalAmount - double.parse(paid)).toString();
          _searchController.text = "";
          _searchText = "";
        });
        _populateInventoryList();
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text('Sorry, Could not add Current Item.'),
            title: Text(
              'Error'.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.blueAccent,
                child: const Text('Okay'),
              )
            ],
          ),
        );
      }
    }
  }

  _removeItem(SoldItem item) {
    List<SoldItem> items = addedItems;
    items.removeWhere((element) =>
        element.name == item.name && element.salesTime == item.salesTime);
    double total = 0;
    for (var element in items) {
      total = total + element.amount;
    }

    var paid = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : '0';
    setState(() {
      addedItems = items;
      totalAmount = total;
      _equivalentAmount.text = totalAmount.toString();
      _balanceController.text = (totalAmount - double.parse(paid)).toString();
    });
  }

  _editAdded(SoldItem obj) {
    List<SoldItem> items = addedItems;
    items.removeWhere((element) =>
        element.name == obj.name && element.salesTime == obj.salesTime);
    double total = 0;
    for (var element in items) {
      total = total + element.amount;
    }

    var paid = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : '0';
    setState(() {
      addedItems = items;
      totalAmount = total;
      _equivalentAmount.text = totalAmount.toString();
      itemName = obj.name;
      _priceController.text = obj.price.toString();
      _quantityController.text = obj.quantity.toString();
      _balanceController.text = (totalAmount - double.parse(paid)).toString();
    });
  }

  _paidChanged(val) {
    var paid = (double.tryParse(_posController.text.trim()) ?? 0) +
        (double.tryParse(_cashController.text.trim()) ?? 0) +
        (double.tryParse(_transferController.text.trim()) ?? 0);

    setState(() {
      _balanceController.text = (totalAmount - paid).toString();
      _amountPaidController.text = paid.toString();
    });
  }

  Future<void> _save() async {
    if (addedItems.isNotEmpty) {
      if (double.parse(_balanceController.text.trim()) > 0) {
        var confm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
                "Your transaction contains a balance! Are you sure you want to proceed?"),
            actions: [
              MaterialButton(
                  color: Colors.grey,
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No")),
              MaterialButton(
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes")),
            ],
          ),
        );
        if (confm == false) {
          return;
        }
      }
      setState(() => _processing = true);
      var attndnt = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      TransactionData trx = TransactionData(
        serialNumber: transactionID + 1,
        customerName: _customerNameController.text.trim(),
        customerAddress: _addressController.text.trim(),
        customerPhoneNumber: _numberCOntroller.text.trim(),
        customerEmail: _emailCOntroller.text.trim(),
        amount: double.parse(_equivalentAmount.text.trim()),
        amountPaid: double.parse(_amountPaidController.text.trim()),
        balance: double.parse(_balanceController.text.trim()),
        time: Timestamp.now(),
        attendant: attndnt.exists ? attndnt.data()!['full name'] : "",
        pos: double.parse(_posController.text.trim()),
        cash: double.parse(_cashController.text.trim()),
        transfer: double.parse(_transferController.text.trim()),
      );

      var transactionObj = await FirebaseFirestore.instance
          .collection('transactions')
          .add(trx.toJson());
      trx.id = transactionObj.id;

      var db = FirebaseFirestore.instance;
      var batch = db.batch();

      for (var item in addedItems) {
        item.transactionID = transactionObj.id;
        // await FirebaseFirestore.instance.collection('sales').add(item.toJson());
        var ref = FirebaseFirestore.instance.collection('sales').doc();
        batch.set(ref, item.toJson());
        var i = await FirebaseFirestore.instance
            .collection("inventory")
            .where("name", isEqualTo: item.name)
            .get();

        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(i.docs.first.id)
            .update({
          "available_quantity":
              i.docs.first.data()['available_quantity'] - item.quantity
        });
      }
      batch.commit();

      _totalAmountController.clear();
      _quantityController.clear();
      _equivalentAmount.clear();
      _amountPaidController.clear();
      _balanceController.clear();
      _customerNameController.clear();
      _numberCOntroller.clear();
      _addressController.clear();
      _emailCOntroller.clear();
      setState(() {
        addedItems = [];
        _processing = false;
      });

      // var companyInfo =
      //     await FirebaseFirestore.instance.collection('profile').get();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SellsDetails(
            transaction: trx,
          ),
        ),
      );
    } else {
      return;
    }
  }

  _update() async {
    if (addedItems.isNotEmpty) {
      if (double.parse(_balanceController.text.trim()) > 0) {
        var confm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
                "Your transaction contains a balance! Are you sure you want to proceed?"),
            actions: [
              MaterialButton(
                  color: Colors.grey,
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No")),
              MaterialButton(
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes")),
            ],
          ),
        );
        if (confm == false) {
          return;
        }
      }
      setState(() => _processing = true);

      var attndnt = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      String trxDocID = await FirebaseFirestore.instance
          .collection("transactions")
          .where("serial number", isEqualTo: widget.transaction!.serialNumber)
          .get()
          .then((values) => values.docs.first.id);

      for (var i in widget.items!) {
        // reference inventory document
        var inv = FirebaseFirestore.instance.collection('inventory').doc(i.id!);
        var q = await inv.get();
        // update inventory document available quantity
        await inv.update({
          "available_quantity": q.data()!['available_quantity'] + i.quantity
        });
        // delete previous sales record
        await FirebaseFirestore.instance
            .collection('sales')
            .doc(i.id!)
            .delete();
      }

      TransactionData trx = TransactionData(
        serialNumber: transactionID + 1,
        customerName: _customerNameController.text.trim(),
        customerAddress: _addressController.text.trim(),
        customerPhoneNumber: _numberCOntroller.text.trim(),
        customerEmail: _emailCOntroller.text.trim(),
        amount: double.parse(_equivalentAmount.text.trim()),
        amountPaid: double.parse(_amountPaidController.text.trim()),
        balance: double.parse(_balanceController.text.trim()),
        time: Timestamp.now(),
        attendant: attndnt.exists ? attndnt.data()!['full name'] : "",
        pos: double.parse(_posController.text.trim()),
        cash: double.parse(_cashController.text.trim()),
        transfer: double.parse(_transferController.text.trim()),
      );

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(trxDocID)
          .update(trx.toJson());

      trx.id = trxDocID;

      var db = FirebaseFirestore.instance;
      var batch = db.batch();

      for (var item in addedItems) {
        item.transactionID = trxDocID;
        // await FirebaseFirestore.instance.collection('sales').add(item.toJson());
        var ref = FirebaseFirestore.instance.collection('sales').doc();
        batch.set(ref, item.toJson());
        var i = await FirebaseFirestore.instance
            .collection("inventory")
            .where("name", isEqualTo: item.name)
            .get();

        await FirebaseFirestore.instance
            .collection('inventory')
            .doc(i.docs.first.id)
            .update({
          "available_quantity":
              i.docs.first.data()['available_quantity'] - item.quantity
        });
      }
      batch.commit();

      _totalAmountController.clear();
      _quantityController.clear();
      _equivalentAmount.clear();
      _amountPaidController.clear();
      _balanceController.clear();
      _customerNameController.clear();
      _numberCOntroller.clear();
      _addressController.clear();
      _emailCOntroller.clear();
      setState(() {
        addedItems = [];
        _processing = false;
      });

      // var companyInfo =
      //     await FirebaseFirestore.instance.collection('profile').get();

      // -----------------------------------------------------------

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SellsDetails(
            transaction: trx,
          ),
        ),
      );
    } else {
      return;
    }
  }

  _populateInventoryList() {
    inventoryItems = [];
    inventoryItems.addAll(
      widget.inventoryData.where(
        (element) => _searchText.isNotEmpty
            ? element.name.toLowerCase().contains(
                  _searchText.trim().toLowerCase(),
                )
            : true,
      ),
    );

    setState(() {
      if (inventoryItems.isNotEmpty) {
        itemName = inventoryItems.first.name;
        _priceController.text = inventoryItems.first.maxPrice.toString();
      }
      if (widget.transaction != null) {
        _editing = true;

        var trx = widget.transaction;

        _customerNameController.text = trx!.customerName;
        _addressController.text = trx.customerAddress;
        _numberCOntroller.text = trx.customerPhoneNumber;
        _emailCOntroller.text = trx.customerEmail;
        _totalAmountController.text = trx.amount.toString();
        _amountPaidController.text = trx.amountPaid.toString();

        _balanceController.text = trx.balance.toString();
        totalAmount = trx.amount;

        _equivalentAmount.text = trx.amount.toString();

        _getEditabeItems();
      } else {
        _amountPaidController.text = "0";
      }
      inventoryItems = inventoryItems;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _totalAmountController.dispose();
    _quantityController.dispose();
    _equivalentAmount.dispose();
    _amountPaidController.dispose();
    _balanceController.dispose();
    _customerNameController.dispose();
    _numberCOntroller.dispose();
    _addressController.dispose();
    _emailCOntroller.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: GridView.count(
        padding: const EdgeInsets.all(8.0),
        childAspectRatio: MediaQuery.of(context).size.width > 480 ? 5 / 3 : 1,
        crossAxisCount: MediaQuery.of(context).size.width > 480 ? 2 : 1,
        children: [
          Card(
            elevation: 5.0,
            child: Column(
              children: [
                Container(
                  color: Colors.tealAccent,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Added Items'),
                      Text("${addedItems.length} items")
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: List.generate(
                      addedItems.length,
                      (index) => ListTile(
                        title: Text(
                            "${addedItems[index].name} X ${addedItems[index].quantity.toString()}"),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem<int>(value: 0, child: Text('Edit')),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text('Remove'),
                              ),
                            ];
                          },
                          onSelected: (item) async {
                            switch (item) {
                              case 0:
                                _editAdded(addedItems[index]);
                                break;
                              case 1:
                                _removeItem(addedItems[index]);
                                break;
                            }
                          },
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Price: ${NumberFormat("###,###,###").format(addedItems[index].price)}"),
                            Text(
                                "Total Amount: ${NumberFormat("###,###,###").format(addedItems[index].amount)}")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    minWidth: double.maxFinite,
                    height: 50.0,
                    color: Colors.teal,
                    onPressed: _processing ? null : () async => await _save(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _processing
                            ? const CircularProgressIndicator()
                            : const Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            _editing ? 'Update' : 'Save',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.tealAccent,
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text('Select Item(s)'),
                        const SizedBox(width: 20),
                        Flexible(
                          child: SizedBox(
                            height: 30,
                            child: TextFormField(
                              controller: _searchController,
                              onChanged: (val) {
                                _searchText = val;
                                _populateInventoryList();
                              },
                              decoration: InputDecoration(
                                suffix: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchText = "";
                                    _searchController.clear();
                                    _populateInventoryList();
                                  },
                                ),
                                // label: const Text("Search"),
                                icon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      isDense: true,
                      value: itemName,
                      hint: const Text("Select Product"),
                      onChanged: (value) => setState(() {
                        itemName = value.toString();

                        maxPrice = inventoryItems
                            .where((element) => element.name == value)
                            .first
                            .maxPrice;
                        minPrice = inventoryItems
                            .where((element) => element.name == value)
                            .first
                            .minPrice;

                        _priceController.text = maxPrice.toString();
                      }),
                      items: inventoryItems
                          // .where(
                          //   (element) => _searchController.text.trim().isEmpty
                          //       ? true
                          //       : element.name
                          //           .toLowerCase()
                          //           .contains(_searchText.toLowerCase()),
                          // )
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.name,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.name),
                                  Text(
                                    " ${item.available_quantity}",
                                    style: const TextStyle(
                                        backgroundColor: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        icon: Icon(Icons.inventory_2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: _priceController,
                            onChanged: (val) => setState(() {
                              _totalAmountController.text =
                                  _quantityController.text.isNotEmpty
                                      ? (double.parse(_priceController.text) *
                                              double.parse(
                                                  _quantityController.text))
                                          .toString()
                                      : '0';
                            }),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              icon: Icon(Icons.price_change),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _totalAmountController,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Total Amount',
                              icon: Icon(Icons.calculate),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(
                                RegExp(r'[0-9.]'),
                                allow: true,
                              ),
                            ],
                            onChanged: (val) => setState(() {
                              _totalAmountController.text =
                                  _quantityController.text.isNotEmpty
                                      ? (double.parse(_priceController.text) *
                                              double.parse(
                                                  _quantityController.text))
                                          .toString()
                                      : '0';
                            }),
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'How many items?',
                              icon: Icon(Icons.calculate),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: GestureDetector(
                            onTap: _addItem,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              width: 50.0,
                              height: 50.0,
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.tealAccent,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: const Text('Payment Infomation'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _equivalentAmount,
                          keyboardType: TextInputType.number,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            icon: Icon(Icons.calculate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _cashController,
                          onChanged: _paidChanged,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cash',
                            hintText: 'Cash Payment',
                            icon: Icon(Icons.calculate),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _posController,
                          onChanged: _paidChanged,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ATM/POS',
                            hintText: 'Using ATM card',
                            icon: Icon(Icons.calculate),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _transferController,
                          onChanged: _paidChanged,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Transfer',
                            hintText: 'Bank Transfer',
                            icon: Icon(Icons.calculate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          controller: _amountPaidController,
                          decoration: const InputDecoration(
                            labelText: 'Amoint Paid',
                            icon: Icon(Icons.remove),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          controller: _balanceController,
                          decoration: const InputDecoration(
                            labelText: 'Balance',
                            hintText: 'Amount Remaining',
                            icon: Icon(Icons.remove),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.tealAccent,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: const Text('Customer Infomation'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _customerNameController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      icon: Icon(Icons.person),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _numberCOntroller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'phone Number of customer',
                            icon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _emailCOntroller,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Customer\'s email',
                            icon: Icon(Icons.email),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Customer\'s address',
                      icon: Icon(Icons.home),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14.0))
        ],
      ),
    );
  }
}
