import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data/data.dart';

class NewInventoryPage extends StatefulWidget {
  final InventoryData? data;
  const NewInventoryPage({Key? key, this.data}) : super(key: key);

  @override
  State<NewInventoryPage> createState() => _NewInventoryPageState();
}

class _NewInventoryPageState extends State<NewInventoryPage> {
  List<InventoryData> itemsAdded = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool saving = false;

  final uuid = const Uuid();

  _updateTotalAmount() {
    var pric =
        _maxPriceController.text.isNotEmpty ? _maxPriceController.text : '0';
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
    _maxPriceController.text = char;
    _maxPriceController.selection = TextSelection.fromPosition(
      TextPosition(offset: _maxPriceController.text.length),
    );
    _updateTotalAmount();
  }

  _addInventoryItem() {
    if (_quantityController.text.isEmpty) {
      _quantityController.text = 1.toString();
    }
    if (_nameController.value.text.isNotEmpty &&
        _minPriceController.value.text.isNotEmpty &&
        _maxPriceController.value.text.isNotEmpty) {
      var item = InventoryData(
        description: _descriptionController.text,
        name: _nameController.value.text,
        available_quantity: double.parse(_quantityController.value.text),
        minPrice: double.parse(_maxPriceController.value.text),
        maxPrice: double.parse(_minPriceController.value.text),
        cost: double.parse(_costController.value.text),
      );
      _nameController.clear();
      _maxPriceController.clear();
      _minPriceController.clear();
      _costController.clear();
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
      for (var item in itemsAdded) {
        await FirebaseFirestore.instance
            .collection('inventory')
            .add(item.toMap());
      }
      setState(() => saving = false);
      Navigator.of(context).pop();
    }
  }

  _updateInventory() async {
    if (_quantityController.text.isEmpty) {
      _quantityController.text = 1.toString();
    }
    if (_nameController.value.text.isNotEmpty &&
        _maxPriceController.value.text.isNotEmpty &&
        _minPriceController.value.text.isNotEmpty) {
      setState(() => saving = true);
      InventoryData obj = InventoryData(
        id: widget.data!.id,
        name: _nameController.value.text,
        description: _descriptionController.text,
        available_quantity: double.parse(_quantityController.value.text),
        minPrice: double.parse(_minPriceController.value.text),
        maxPrice: double.parse(_maxPriceController.value.text),
        cost: double.parse(_costController.value.text),
      );
      FirebaseFirestore.instance
          .collection('inventory')
          .doc(obj.id)
          .update(obj.toMap())
          .then((value) => setState(() => saving = false))
          .then(
        (value) {
          Navigator.of(context).pop();
        },
      );
    }
  }

  _deleteInventory(String id) async {
    setState(() {
      saving = true;
    });
    var res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.dangerous),
        content: const Text(
            "Are you sure you want to delete this item from inventory?"),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Colors.grey,
            child: const Text("NO"),
          ),
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(true),
            color: const Color.fromARGB(255, 253, 17, 0),
            child: const Text("YES"),
          ),
        ],
      ),
    );
    if (res) {
      await FirebaseFirestore.instance.collection('inventory').doc(id).delete();
      setState(() {
        saving = false;
      });
      Navigator.of(context).pop();
    }
    setState(() {
      saving = false;
    });
    return;
  }

  @override
  void dispose() {
    super.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _costController.dispose();
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
      _minPriceController.text = d.minPrice.toString();
      _maxPriceController.text = d.maxPrice.toString();
      _costController.text = d.cost.toString();
      _quantityController.text = d.available_quantity.toString();
      _nameController.text = d.name;
      _descriptionController.text = d.description;
      editing = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
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
                      padding: const EdgeInsets.all(12.0),
                      child: const Text('Insert Item(s)'),
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
                          Flexible(
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _costController,
                              keyboardType: TextInputType.number,
                              onChanged: editing ? null : _priceCanged,
                              decoration: const InputDecoration(
                                labelText: 'Cost',
                                icon: Icon(Icons.price_change),
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              onChanged: editing ? null : _priceCanged,
                              decoration: const InputDecoration(
                                labelText: 'Min Price',
                                icon: Icon(Icons.price_change),
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              onChanged: editing ? null : _priceCanged,
                              decoration: const InputDecoration(
                                labelText: 'Max Price',
                                icon: Icon(Icons.price_change),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(9),
                      child: Row(
                        children: [
                          Flexible(
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
                          Flexible(
                            child: !editing
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
                          ),
                        ],
                      ),
                    ),
                    editing
                        ? saving
                            ? const CircularProgressIndicator()
                            : Row(
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: MaterialButton(
                                        minWidth: double.maxFinite,
                                        height: 50.0,
                                        color: Colors.teal,
                                        onPressed:
                                            saving ? null : _updateInventory,
                                        child: saving
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Update',
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                  widget.data!.id != null
                                      ? Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: MaterialButton(
                                              minWidth: double.maxFinite,
                                              height: 50.0,
                                              color: const Color.fromARGB(
                                                  255, 245, 16, 0),
                                              onPressed: () => _deleteInventory(
                                                  widget.data!.id!),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
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
                            padding: const EdgeInsets.all(12.0),
                            child: const Text('Added Items'),
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
                                        itemsAdded.removeWhere((element) =>
                                            element.name == e.name);
                                      });
                                      break;
                                    case 1:
                                      setState(
                                        () {
                                          _minPriceController.text =
                                              e.minPrice.toString();
                                          _maxPriceController.text =
                                              e.maxPrice.toString();
                                          _costController.text =
                                              e.cost.toString();
                                          _descriptionController.text =
                                              e.description;
                                          _nameController.text = e.name;
                                          _quantityController.text =
                                              e.available_quantity.toString();
                                          itemsAdded.removeWhere((element) =>
                                              element.name == e.name);
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
                                  Text('Quantity: ${e.available_quantity}'),
                                  Text(
                                      'Total Amount: ${e.maxPrice * e.available_quantity}')
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
