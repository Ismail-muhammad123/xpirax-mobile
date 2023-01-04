import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:xpirax/data/transaction.dart';

import '../../providers/web_database_providers.dart';

class SellsDetails extends StatefulWidget {
  final Transaction transaction;
  final String? companyName;
  const SellsDetails({Key? key, required this.transaction, this.companyName})
      : super(key: key);

  @override
  State<SellsDetails> createState() => _SellsDetailsState();
}

class _SellsDetailsState extends State<SellsDetails> {
  final GlobalKey genKey = GlobalKey();
  void _printReciept(photoName) async {
    // Get image of the current widget
    RenderRepaintBoundary? boundary =
        genKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    ui.Image? image = await boundary?.toImage();
    ByteData? byteData = await image?.toByteData(
      format: ui.ImageByteFormat.png,
    );
    // Read the image as bytes
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    // Write the image bytes to a temporary file

    if (Platform.isIOS) {
      // method not implemented for ios devices
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content:
              Text("This action is not supported on this type of device, yet."),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
              color: Colors.teal,
            ),
          ],
        ),
      );
      return;
    }

    var directory = (await getExternalStorageDirectory())!.path;

    File imgFile = await File(path.join(
            directory, 'Transaction-Reciepts', 'Reciept-$photoName.jpg'))
        .create(recursive: true);
    var file = await imgFile.writeAsBytes(pngBytes!);

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'Download Reciept',
        onPressed: () async => _printReciept(widget.transaction.uid),
        child: const Icon(Icons.download),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Transaction Reciept'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 8.0,
              child: RepaintBoundary(
                key: genKey,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0, top: 8.0),
                        child: FutureBuilder<String>(
                            future: context
                                .read<Authentication>()
                                .getOfflineBusinessName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return Text(
                                snapshot.data!.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 480
                                          ? 48.0
                                          : 30.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              );
                            }),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Transaction Reciept",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              color: Colors.teal,
                              padding: const EdgeInsets.all(8.0),
                              width: double.maxFinite,
                              child: Text(
                                'Customer Information:'.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 12.0)),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Name:'),
                                      Text(widget.transaction.customerName),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Phone Number:'),
                                      Text(widget.transaction.phoneNumber),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Email:'),
                                      Text(widget.transaction.email),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Address:'),
                                      Text(
                                        widget.transaction.address,
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            Container(
                              alignment: Alignment.center,
                              color: Colors.teal,
                              padding: const EdgeInsets.all(8.0),
                              width: double.maxFinite,
                              child: Text(
                                'Items Bought'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Center(
                              child: DataTable(
                                headingRowHeight: 35,
                                dataRowHeight: 25.0,
                                columnSpacing: 15.0,
                                dataTextStyle: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                headingTextStyle: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal,
                                ),
                                columns: ['name', 'price', 'Qty', 'amount']
                                    .map(
                                      (e) => DataColumn(
                                        label: Text(e.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                rows: widget.transaction.items!
                                    .map(
                                      (e) => DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: 100.0,
                                              child: Text(e.name),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              NumberFormat('###,###,###')
                                                  .format(e.price),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              NumberFormat('###,###,###')
                                                  .format(e.quantity),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              NumberFormat('###,###,###')
                                                  .format(e.price * e.quantity),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            Container(
                              alignment: Alignment.center,
                              color: Colors.teal,
                              padding: const EdgeInsets.all(8.0),
                              width: double.maxFinite,
                              child: Text(
                                'Payment'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Transaction ID:'),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          widget.transaction.uid,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Date:'),
                                      Text(DateFormat.yMMMMEEEEd()
                                          .format(
                                            DateTime.parse(
                                                widget.transaction.date!),
                                          )
                                          .toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Time:'),
                                      Text(DateFormat()
                                          .add_jm()
                                          .format(
                                            DateTime.parse(
                                                widget.transaction.date!),
                                          )
                                          .toString()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Amount:'),
                                      Text(
                                        NumberFormat('###,###,###')
                                            .format(widget.transaction.amount),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Discound:'),
                                      Text(
                                        NumberFormat('###,###,###').format(
                                            widget.transaction.discount),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total Amount:'),
                                      Text(
                                        NumberFormat('###,###,###').format(
                                            widget.transaction.amount -
                                                widget.transaction.discount),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Amount Paid'),
                                      Text(
                                        NumberFormat('###,###,###').format(
                                            widget.transaction.amountPaid),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Balance'),
                                      Text(
                                        NumberFormat('###,###,###')
                                            .format(widget.transaction.balance),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 22.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
