import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xpirax/data/cart_data.dart';
import 'package:xpirax/data/inventory.dart';
import 'package:xpirax/pages/sells/sellsDetails.dart';
import 'package:uuid/uuid.dart';
import 'package:xpirax/providers/database/dataBase_manager.dart';
import 'package:xpirax/providers/web_database_providers.dart';

class NewInventoryPage extends StatefulWidget {
  final Inventory? data;
  const NewInventoryPage({Key? key, this.data}) : super(key: key);

  @override
  State<NewInventoryPage> createState() => _NewInventoryPageState();
}

class _NewInventoryPageState extends State<NewInventoryPage> {
  List<Inventory> itemsAdded = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool saving = false;

  final uuid = const Uuid();

  _updateTotalAmount() {
    var pric = _priceController.text.isNotEmpty ? _priceController.text : '0';
    var quant =
        _quantityController.text.isNotEmpty ? _quantityController.text : '0';
    _totalAmountController.text =
        (double.parse(quant) * double.parse(pric)).toString();
  }

  _quantityCanged(String char) {
    _quantityController.text = char;
    _quantityController.selection = TextSelection.fromPosition(
      TextPosition(offset: _quantityController.text.length),
    );
    _updateTotalAmount();
  }

  _priceCanged(String char) {
    _priceController.text = char;
    _priceController.selection = TextSelection.fromPosition(
      TextPosition(offset: _priceController.text.length),
    );
    _updateTotalAmount();
  }

  _addInventoryItem() {
    if (_quantityController.text.isEmpty) {
      _quantityController.text = 1.toString();
    }
    if (_nameController.value.text.isNotEmpty &&
        _priceController.value.text.isNotEmpty) {
      var item = Inventory(
        uid: const Uuid().v4(),
        description: _descriptionController.text,
        name: _nameController.value.text,
        availableQuantity: int.parse(_quantityController.value.text),
        price: double.parse(_priceController.value.text),
      );
      _nameController.clear();
      _priceController.clear();
      _totalAmountController.clear();
      _descriptionController.clear();
      _quantityController.clear();
      setState(() {
        itemsAdded.add(item);
      });
    }
  }

  _saveInventoryItems() async {
    if (itemsAdded.isNotEmpty) {
      setState(() => saving = true);
      context
          .read<LocalDatabaseHandler>()
          .insertItemsToInventory(itemsAdded)
          .then((value) => setState(() => saving = false))
          .then(
        (value) {
          Navigator.of(context).pop();
        },
      );
    }
  }

  _updateInventory() async {
    if (_quantityController.text.isEmpty) {
      _quantityController.text = 1.toString();
    }
    if (_nameController.value.text.isNotEmpty &&
        _priceController.value.text.isNotEmpty) {
      setState(() => saving = true);
      Inventory obj = Inventory(
        uid: widget.data!.uid,
        name: _nameController.value.text,
        description: _descriptionController.text,
        availableQuantity: int.parse(_quantityController.value.text),
        price: double.parse(_priceController.value.text),
      );
      context
          .read<LocalDatabaseHandler>()
          .updateInventoryItem(obj)
          .then((value) => setState(() => saving = false))
          .then(
        (value) {
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _totalAmountController.dispose();
  }

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      var d = widget.data!;
      _priceController.text = d.price.toString();
      _quantityController.text = d.availableQuantity.toString();
      _nameController.text = d.name;
      _descriptionController.text = d.description;
      editing = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add To Inventory'.toUpperCase()),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              child: Card(
                elevation: 5.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.tealAccent,
                      width: double.maxFinite,
                      padding: EdgeInsets.all(12.0),
                      child: Text('Insert Item(s)'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          hintText: 'Enter the name of customer',
                          icon: Icon(Icons.inventory_2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          icon: Icon(Icons.note),
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
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              onChanged: editing ? null : _priceCanged,
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                icon: Icon(Icons.price_change),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              onChanged: editing ? null : _quantityCanged,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                icon: Icon(Icons.format_list_numbered),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    !editing
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _totalAmountController,
                              decoration: const InputDecoration(
                                enabled: false,
                                labelText: 'Total Amount',
                                icon: Icon(Icons.calculate),
                              ),
                            ),
                          )
                        : Container(),
                    editing
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                              minWidth: double.maxFinite,
                              height: 50.0,
                              color: Colors.teal,
                              onPressed: saving ? null : _updateInventory,
                              child: saving
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.update,
                                          color: Colors.white,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Update',
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
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: IconButton(
                                  iconSize: 30,
                                  color: Colors.green,
                                  icon: const Icon(Icons.add),
                                  onPressed: _addInventoryItem,
                                ),
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ),
            !editing
                ? SizedBox(
                    child: Card(
                      elevation: 5.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.tealAccent,
                            width: double.maxFinite,
                            padding: EdgeInsets.all(12.0),
                            child: Text('Added Items'),
                          ),
                          ...itemsAdded.map(
                            (e) => ListTile(
                              title: Text(e.name),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) {
                                  return const [
                                    PopupMenuItem<int>(
                                        value: 0, child: Text('Remove')),
                                    PopupMenuItem<int>(
                                        value: 1, child: Text('Edit'))
                                  ];
                                },
                                onSelected: (item) {
                                  switch (item) {
                                    case 0:
                                      setState(() {
                                        itemsAdded.removeWhere(
                                            (element) => element.uid == e.uid);
                                      });
                                      break;
                                    case 1:
                                      setState(
                                        () {
                                          _priceController.text =
                                              e.price.toString();
                                          _descriptionController.text =
                                              e.description;
                                          _nameController.text = e.name;
                                          _quantityController.text =
                                              e.availableQuantity.toString();
                                          itemsAdded.removeWhere(
                                              (element) => element == e);
                                        },
                                      );
                                      break;
                                  }
                                },
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Quantity: ${e.availableQuantity}'),
                                  Text(
                                      'ToTal Amount: ${e.price * e.availableQuantity}')
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                              minWidth: double.maxFinite,
                              height: 50.0,
                              color: Colors.teal,
                              onPressed: _saveInventoryItems,
                              child: saving
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
