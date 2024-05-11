import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:sanitary_mart_admin/core/app_util.dart';
import 'package:sanitary_mart_admin/order/model/order_model.dart';
import 'package:sanitary_mart_admin/order/model/order_status.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareOrderAsPdf(BuildContext context, OrderModel order) async {
  pw.Document pdf = createPdfDocument(order);

  // Get the directory for storing PDF files
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  // Save the PDF document to a file
  Uint8List file = await pdf.save();
  final filePath = '$path/order_${order.orderId}.pdf';
  File(filePath).writeAsBytesSync(file);

  // Share the PDF file
  // You can use any method to share the file, such as Share package or sending it via email
  // For example, you can use Share package:
  await Share.shareFiles([filePath], text: 'Order ${order.orderId}');
}

Future<String> getExternalDocumentPath() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  Directory _directory = Directory("");
  if (Platform.isAndroid) {
    _directory = Directory("/storage/emulated/0/Download");
  } else {
    _directory = await getApplicationDocumentsDirectory();
  }

  final exPath = _directory.path;
  print("Saved Path: $exPath");
  await Directory(exPath).create(recursive: true);
  return exPath;
}


Future<void> downloadOrderAsPdf(BuildContext context, OrderModel order) async {
  pw.Document pdf = createPdfDocument(order);
  final path = await getExternalDocumentPath();
  final filePath = join(path, 'order_${order.orderId}.pdf');  // Combine path and filename
  if (!await Directory(path).exists()) {
    AppUtil.showToast('Unable to create folder');
    return;
  }
  Uint8List bytes = await pdf.save();
  File filed = File(filePath);
  await filed.writeAsBytes(bytes,mode: FileMode.write);
  AppUtil.showToast('Bill downloaded successfully');
}


pw.Document createPdfDocument(OrderModel order) {
  double total = 0;
  double discount = 0;

  // Calculate total and discount based on order items
  for (var item in order.orderItems) {
    total += item.price * item.quantity;
    discount += item.discountAmount * item.quantity;
  }

  // Create a PDF document
  final pdf = pw.Document();

  // Add content to the PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Container(
        padding: const pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Shree Balaji Sanitary & Electronics',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Bhiwani Road, Bahal',
                style: const pw.TextStyle(fontSize: 16)),
            pw.Text('Phone: 9555294879',
                style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Text('Order ID: ${order.orderId}',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ${_formatDate(order.createdAt)}',
                style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Status:', style: const pw.TextStyle(fontSize: 16)),
                pw.Text(
                  '${order.orderStatus.name.capitalize}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                      color: _getStatusColor(order.orderStatus)),
                ),
              ],
            ),
            pw.Divider(),
            pw.Text('Items:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ['Sr', 'Items', 'Qty', 'Price'],
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 14),
              data: order.orderItems.map((item) {
                return [
                  (order.orderItems.indexOf(item) + 1).toString(),
                  item.productName,
                  item.quantity.toString(),
                  (item.price).toStringAsFixed(2),
                ];
              }).toList(),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total:', style: const pw.TextStyle(fontSize: 16)),
                pw.Text(
                  total.toStringAsFixed(2),
                  style: const pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (discount > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Point:',
                    style: const pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    (discount / 10).toStringAsFixed(2),
                    style: const pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
  return pdf;
}

String _formatDate(int? timestamp) {
  if (timestamp == null) return 'Unknown date';
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat.yMMMd().format(date); // Example format: Jan 28, 2020
}

PdfColor _getStatusColor(OrderStatus orderStatus) {
  switch (orderStatus) {
    case OrderStatus.pending:
      return PdfColors.purple;
    case OrderStatus.delivered:
      return PdfColors.green;
    case OrderStatus.canceled:
      return PdfColors.red;
    case OrderStatus.returned:
      return PdfColors.orange;
    default:
      return PdfColors.black;
  }
}
