import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client.dart';
import '../models/product.dart';

Future<void> generatePDF(Client client, Product product) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        children: [
          pw.Text("Service Invoice", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text("Client: ${client.name}"),
          pw.Text("Phone: ${client.phone}"),
          pw.Text("Product: ${product.model}"),
          pw.Text("Issue: ${product.issue}"),
          pw.Text("Service Status: ${product.status}"),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
