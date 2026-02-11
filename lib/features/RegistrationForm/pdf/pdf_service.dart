import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generatePatientPdf({
    required String name,
    required String phone,
    required String address,
    required String branch,
    required String bookingDate,
    required List<Map<String, dynamic>> treatments,
    required double total,
    required double discount,
    required double advance,
    required double balance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PATIENT RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('Date: $bookingDate'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Patient Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Name: $name'),
              pw.Text('Phone: $phone'),
              pw.Text('Address: $address'),
              pw.Text('Branch: $branch'),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: [
                  'Sl No',
                  'Treatment',
                  'Price',
                  'Male',
                  'Female',
                  'Total',
                ],
                data: List.generate(treatments.length, (index) {
                  final t = treatments[index];
                  return [
                    '${index + 1}',
                    t['name'],
                    t['price'].toString(),
                    t['male'].toString(),
                    t['female'].toString(),
                    (double.parse(t['price'].toString()) *
                            (t['male'] + t['female']))
                        .toStringAsFixed(2),
                  ];
                }),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Amount: ${total.toStringAsFixed(2)}'),
                      pw.Text('Discount: ${discount.toStringAsFixed(2)}'),
                      pw.Text('Advance: ${advance.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text(
                        'Balance: ${balance.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Thank you for choosing Noviindus Technologies'),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
