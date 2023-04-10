import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import '../../data/data.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SellsDetails extends StatefulWidget {
  final TransactionData transaction;
  const SellsDetails({Key? key, required this.transaction}) : super(key: key);

  @override
  State<SellsDetails> createState() => _SellsDetailsState();
}

class _SellsDetailsState extends State<SellsDetails> {
  var companyInfo = {};
  List<SoldItem> soldItems = [];

  final GlobalKey genKey = GlobalKey();
  void _downloadRecieptPDF(photoName) async {
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
          content: Text("This action is not supported on your device."),
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

  void _printReciept() async {
    // setState(() => isPrinting = true);

    final pdf = pw.Document();

    var format =
        const PdfPageFormat(PdfPageFormat.mm * 65, 200 * PdfPageFormat.mm);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: _generateRecieptContent(
                soldItems,
                font,
              ),
            )
          ];
        },
      ),
    ); // Page

    // var printer = await Printing.pickPrinter(context: context);
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      format: format,
      usePrinterSettings: true,
    );

    // if (printer != null) {
    //   var res = await Printing.directPrintPdf(
    //     printer: printer,
    //     onLayout: (_) => pdf.save(),
    //     format: format,
    //     usePrinterSettings: true,
    //   );
    // }
    // setState(() => isPrinting = false);
  }

  _generateRecieptContent(List<SoldItem> items, pw.Font font) {
    var recieptTitleStyle = pw.TextStyle(
      fontSize: 16.0,
      color: PdfColor.fromHex("#000000"),
    );
    var recieptHeadingStyle = pw.TextStyle(
      fontSize: 10.0,
      color: PdfColor.fromHex("#000000"),
    );
    var recieptBodyStyle = pw.TextStyle(
      fontSize: 10.0,
      color: PdfColor.fromHex("#000000"),
    );

    var contents = [
      // Title
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            companyInfo['businessName']!.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: recieptTitleStyle,
          ),
        ],
      ),

      // Date and Time
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(companyInfo['address'],
              textAlign: pw.TextAlign.center, style: recieptBodyStyle),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(companyInfo['phone'],
              textAlign: pw.TextAlign.center, style: recieptBodyStyle),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(companyInfo['email'],
              textAlign: pw.TextAlign.center, style: recieptBodyStyle),
        ],
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
              "Date: ${DateFormat.yMMMMEEEEd().format(
                widget.transaction.time.toDate(),
              )}",
              textAlign: pw.TextAlign.center,
              style: recieptBodyStyle),
        ],
      ),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            "Transaction ID: ${widget.transaction.id}",
            textAlign: pw.TextAlign.center,
            style: recieptBodyStyle.copyWith(fontSize: 8.0),
          ),
        ],
      ),

      pw.SizedBox(height: 10),

      pw.Table(
        border: pw.TableBorder.all(),
        children: [
          pw.TableRow(
            children: [
              // Headings
              pw.Text("QTY", style: recieptHeadingStyle),
              pw.Text("NAME", style: recieptHeadingStyle),
              pw.Text("PRICE", style: recieptHeadingStyle),
              pw.Text("AMOUNT", style: recieptHeadingStyle),
            ],
          ),
          ...items.map(
            (e) => pw.TableRow(
              children: [
                pw.Text(
                    NumberFormat("###,###,###,###", "en_US").format(e.quantity),
                    style: recieptBodyStyle),
                pw.Text(e.name, style: recieptBodyStyle),
                pw.Text(
                    NumberFormat("###,###,###,###", "en_US").format(e.price),
                    style: recieptBodyStyle),
                pw.Text(
                    NumberFormat("###,###,###,###", "en_US").format(e.amount),
                    style: recieptBodyStyle),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 4.0),
      pw.Divider(),
      pw.SizedBox(height: 4.0),

      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 8.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Amount:",
                style: recieptBodyStyle, textAlign: pw.TextAlign.right),
            pw.Text(
              NumberFormat("###,###,###,###", "en_US")
                  .format(widget.transaction.amount),
              style: recieptBodyStyle,
            ),
          ],
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 8.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Amount Paid:",
                style: recieptBodyStyle, textAlign: pw.TextAlign.right),
            pw.Text(
              NumberFormat("###,###,###,###", "en_US")
                  .format(widget.transaction.amountPaid),
              style: recieptBodyStyle,
            ),
          ],
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 8.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Balance:",
                style: recieptBodyStyle, textAlign: pw.TextAlign.right),
            pw.Text(
              NumberFormat("###,###,###,###", "en_US")
                  .format(widget.transaction.balance),
              style: recieptBodyStyle,
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 4.0),

      pw.Divider(),
      pw.SizedBox(height: 4.0),

      pw.SizedBox(height: 10.0),
      pw.Text(
        "Thank You",
        textAlign: pw.TextAlign.right,
        style: recieptBodyStyle.copyWith(
          fontItalic: pw.Font.timesItalic(),
        ),
      ),
    ];

    return contents;
  }

  @override
  void initState() {
    // get company name and other info
    FirebaseFirestore.instance
        .collection('profile')
        .get()
        .then((value) => setState(() => companyInfo = value.docs.first.data()));
    // get sold items
    FirebaseFirestore.instance
        .collection('sales')
        .where('transactionUid', isEqualTo: widget.transaction.id)
        .get()
        .then(
          (value) => setState(
            () => soldItems = value.docs
                .map(
                  (e) => SoldItem(
                    name: e.data()['name'],
                    quantity: e.data()['quantity'],
                    price: e.data()['price'],
                    amount: e.data()['amount'],
                    salesTime: e.data()['salesTime'],
                  ),
                )
                .toList(),
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: 'Download Reciept',
          onPressed: () async => _downloadRecieptPDF(widget.transaction.id),
          child: const Icon(Icons.download),
        ),
        const SizedBox(height: 10.0),
        FloatingActionButton(
          heroTag: 'Print Reciept',
          onPressed: () async => _printReciept(),
          child: const Icon(Icons.print),
        ),
      ]),
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
                        child: Text(
                          (companyInfo['businessName'] ?? "").toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: MediaQuery.of(context).size.width > 480
                                ? 48.0
                                : 30.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        companyInfo['address'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        companyInfo['phone'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        companyInfo['email'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Transaction Reciept",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
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
                                      Text(widget
                                          .transaction.customerPhoneNumber),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Email:'),
                                      Text(widget.transaction.customerEmail),
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
                                        widget.transaction.customerAddress,
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
                                rows: soldItems
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
                                          widget.transaction.id ?? "...",
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
                                            widget.transaction.time.toDate(),
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
                                            widget.transaction.time.toDate(),
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
