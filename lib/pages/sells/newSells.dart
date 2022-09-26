import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpirax/data/cart_data.dart';
import 'package:xpirax/data/database.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/data/transaction.dart';
import 'package:xpirax/pages/sells/sellsDetails.dart';
import 'package:xpirax/providers/web_database_providers.dart';
import 'package:uuid/uuid.dart';

import 'package:provider/provider.dart';

class SellsForm extends StatefulWidget {
  final Transaction? trx;
  const SellsForm({
    Key? key,
    this.trx,
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
      body: FutureBuilder<List<Inventory>?>(
        future: context.watch<InventoryProvider>().getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return NewSellsPage(
              inventoryData: snapshot.data!
                  .where((element) => element.availableQuantity > 0)
                  .toList(),
              transaction: widget.trx,
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
  final List<Inventory> inventoryData;
  final Transaction? transaction;
  const NewSellsPage({
    Key? key,
    required this.inventoryData,
    this.transaction,
  }) : super(key: key);

  @override
  State<NewSellsPage> createState() => NewSellsPageState();
}

class NewSellsPageState extends State<NewSellsPage> {
  String itemName = '';
  List<Inventory> inventoryItems = [];
  List<Items> addedItems = [];
  bool _saving = false;

  late String _transactionID;

  _getEditabeItems() => setState(() => addedItems = widget.transaction!.items!);

  @override
  void initState() {
    super.initState();
    inventoryItems.addAll(widget.inventoryData);

    if (inventoryItems.isNotEmpty) {
      itemName = inventoryItems.first.name;
      _priceController.text = inventoryItems.first.price.toString();
    }

    if (widget.transaction != null) {
      _editing = true;

      var trx = widget.transaction!;

      _customerNameController.text = trx.customerName;
      _addressController.text = trx.address;
      _numberCOntroller.text = trx.phoneNumber;
      _emailCOntroller.text = trx.email;
      _totalAmountController.text = trx.amount.toString();
      _amountPaidController.text = trx.amountPaid.toString();

      _balanceController.text = trx.balance.toString();
      totalAmount = trx.amount + trx.discount as double;

      _equivalentAmount.text = (trx.amount + trx.discount).toString();
      _discountController.text = trx.discount.toString();

      _getEditabeItems();
      _discountChanged(trx.discount.toString());
    } else {
      _amountPaidController.text = "0";
      _discountController.text = '0';
    }

    _transactionID = uid.v4();
  }

  // input controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _equivalentAmount = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _numberCOntroller = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailCOntroller = TextEditingController();
  final uid = Uuid();

  bool _editing = false;
  double totalAmount = 0;
  double payableamount = 0;

  _addItem() {
    if (_quantityController.text.isNotEmpty) {
      var selected =
          inventoryItems.where((element) => element.name == itemName).first;
      if (selected.availableQuantity <
          double.parse(_quantityController.text.trim())) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6.0)),
                Text("Alert"),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.blue,
                child: Text("OK"),
              ),
            ],
            content: Text(
                "The quantity selected for this item is greater that what is available in Stock!"),
          ),
        );
        return;
      }
      try {
        var obj = Items(
          item: selected.id!,
          itemName: selected.name,
          quantity: int.parse(_quantityController.text),
          price: double.parse(_priceController.text.trim()),
          // item quantity
        );

        if (addedItems.contains(obj)) {
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
        List<Items> items = [];
        items.add(obj);
        var discount = _discountController.text.isNotEmpty
            ? _discountController.text
            : '0';
        var paid = _amountPaidController.text.isNotEmpty
            ? _amountPaidController.text
            : '0';

        setState(() {
          addedItems = addedItems + items;
          totalAmount = totalAmount +
              (selected.price * int.parse(_quantityController.text)) -
              double.parse(_discountController.text);
          _equivalentAmount.text = totalAmount.toString();
          _quantityController.clear();
          _paymentAmountController.text =
              (totalAmount - double.parse(discount)).toString();
          _balanceController.text =
              (totalAmount - double.parse(discount) - double.parse(paid))
                  .toString();
        });
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
                child: const Text('Okay'),
                color: Colors.blueAccent,
              )
            ],
          ),
        );
      }
    }
  }

  _removeItem(String name) {
    List<Items> items = addedItems;
    items.removeWhere((element) => element.itemName == name);
    double total = 0;
    for (var element in items) {
      total = total + (element.price * element.quantity);
    }
    var discount =
        _discountController.text.isNotEmpty ? _discountController.text : '0';
    var paid = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : '0';
    setState(() {
      addedItems = items;
      totalAmount = total;
      _equivalentAmount.text = totalAmount.toString();
      _paymentAmountController.text =
          (totalAmount - double.parse(discount)).toString();
      _balanceController.text =
          (totalAmount - double.parse(discount) - double.parse(paid))
              .toString();
    });
  }

  _editAdded(Items obj) {
    List<Items> items = addedItems;
    items.removeWhere((element) => element.id == obj.id);
    double total = 0;
    items.forEach(
        (element) => total = total + (element.price * element.quantity));
    var discount =
        _discountController.text.isNotEmpty ? _discountController.text : '0';
    var paid = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : '0';
    setState(() {
      addedItems = items;
      totalAmount = total;
      _equivalentAmount.text = totalAmount.toString();
      itemName = obj.itemName;
      _priceController.text = obj.price.toString();
      _quantityController.text = obj.quantity.toString();
      _paymentAmountController.text =
          (totalAmount - double.parse(discount)).toString();
      _balanceController.text =
          (totalAmount - double.parse(discount) - double.parse(paid))
              .toString();
    });
  }

  _paidChanged(val) {
    var discount =
        _discountController.text.isNotEmpty ? _discountController.text : '0';
    var paid = _amountPaidController.text.isNotEmpty ? val : '0';

    setState(() {
      _paymentAmountController.text =
          (totalAmount - double.parse(discount)).toString();
      _balanceController.text =
          (totalAmount - double.parse(discount) - double.parse(paid))
              .toString();
    });
  }

  _discountChanged(val) {
    var discount = _discountController.text.isNotEmpty ? val : '0';
    var paid = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : '0';

    setState(() {
      _paymentAmountController.text =
          (totalAmount - double.parse(discount)).toString();
      _balanceController.text =
          (totalAmount - double.parse(discount) - double.parse(paid))
              .toString();
    });
  }

  _save() async {
    if (addedItems.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Atleast One Item Must be added"),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Okay"),
              color: Colors.blue,
            )
          ],
        ),
      );
      return;
    }
    Transaction trx = Transaction(
      customerName: _customerNameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _numberCOntroller.text.trim(),
      email: _emailCOntroller.text.trim(),
      amount: double.parse(_paymentAmountController.text.trim()),
      amountPaid: double.parse(_amountPaidController.text.trim()),
      discount: double.parse(_discountController.text.trim()),
      balance: double.parse(_balanceController.text.trim()),
      date: DateTime.now().toString(),
      items: addedItems,
    );
    setState(() {
      _saving = true;
    });
    // insert the created transaction
    Transaction? res = await context
        .read<TransactionsProvider>()
        .insertTransaction(transaction: trx);
    setState(
      () => _saving = false,
    );
    if (res == null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Transaction failed"),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Okay"),
              color: Colors.blue,
            )
          ],
        ),
      );
      setState(() => addedItems = []);
      return;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SellsDetails(
            transaction: res,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _totalAmountController.dispose();
    _quantityController.dispose();
    _equivalentAmount.dispose();
    _discountController.dispose();
    _paymentAmountController.dispose();
    _amountPaidController.dispose();
    _balanceController.dispose();
    _customerNameController.dispose();
    _numberCOntroller.dispose();
    _addressController.dispose();
    _emailCOntroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: GridView.count(
        padding: EdgeInsets.all(8.0),
        childAspectRatio: MediaQuery.of(context).size.width > 480 ? 4 / 2 : 1,
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
                        title: Text(addedItems[index].itemName +
                            addedItems[index].quantity.toString()),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem<int>(value: 0, child: Text('Edit')),
                              PopupMenuItem<int>(
                                  value: 1, child: Text('Remove')),
                            ];
                          },
                          onSelected: (item) async {
                            switch (item) {
                              case 0:
                                _editAdded(addedItems[index]);
                                break;
                              case 1:
                                _removeItem(addedItems[index].itemName);
                                break;
                            }
                          },
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Price: ${addedItems[index].price}"),
                            Text(
                                "ToTal Amount: ${addedItems[index].price * addedItems[index].quantity}")
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
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.tealAccent,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12.0),
                  child: const Text('Select Item(s)'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField(
                    value: itemName,
                    onChanged: (value) => setState(() {
                      itemName = value.toString();
                      _priceController.text = inventoryItems
                          .where((element) => element.name == value)
                          .first
                          .price
                          .toString();
                    }),
                    items: List.generate(
                      inventoryItems.length,
                      (index) => DropdownMenuItem(
                        value: inventoryItems[index].name,
                        child: Text(
                            "${inventoryItems[index].name}   (${inventoryItems[index].availableQuantity} available)"),
                      ),
                    ),
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
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            icon: Icon(Icons.price_change),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _totalAmountController,
                          keyboardType: TextInputType.number,
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
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (val) => setState(() {
                      _totalAmountController.text =
                          _quantityController.text.isNotEmpty
                              ? (double.parse(_priceController.text) *
                                      int.parse(_quantityController.text))
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                )
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
                  padding: EdgeInsets.all(12.0),
                  child: Text('Payment Infomation'),
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
                      Expanded(
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _discountChanged,
                          controller: _discountController,
                          decoration: const InputDecoration(
                            labelText: 'Discount',
                            hintText: 'Enter Discounted amount',
                            icon: Icon(Icons.remove),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _paymentAmountController,
                    keyboardType: TextInputType.number,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount',
                      icon: Icon(Icons.calculate),
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
                          controller: _amountPaidController,
                          onChanged: _paidChanged,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount Paid',
                            hintText: 'How much is being payed',
                            icon: Icon(Icons.calculate),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: false,
                          controller: _balanceController,
                          decoration: const InputDecoration(
                            labelText: 'Amount Remaining',
                            hintText: 'Amount left',
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
                  padding: EdgeInsets.all(12.0),
                  child: Text('Customer Infomation'),
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
                  padding: EdgeInsets.all(8.0),
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
