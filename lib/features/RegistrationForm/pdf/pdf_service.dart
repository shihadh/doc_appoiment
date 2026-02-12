import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/image_const.dart';

class PdfService {
  static Future<void> generatePatientPdf({
    required String name,
    required String phone,
    required String address,
    required String branch,
    required String bookingDate,
    required String treatmentDate,
    required String treatmentTime,
    required List<Map<String, dynamic>> treatments,
    required double total,
    required double discount,
    required double advance,
    required double balance,
  }) async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle(ImageConst.logo);
    final sign = await imageFromAssetBundle(ImageConst.sign);
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Watermark
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(logo, width: 400),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Image(logo, width: 80),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'KUMARAKOM',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Cheepunkal P.O. Kumarakom, kottayam, Kerala - 686563',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'e-mail: unknown@gmail.com',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'Mob: +91 9876543210 | +91 9786543210',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'GST No: 32AABCU9603R1ZW',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 0.5),
                  pw.SizedBox(height: 20),

                  // Patient Details Title
                  pw.Text(
                    'Patient Details',
                    style: pw.TextStyle(
                      color: PdfColors.green,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Patient Info Row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Name', name),
                          _buildInfoRow('Address', address),
                          _buildInfoRow('WhatsApp Number', phone),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Booked On', bookingDate),
                          _buildInfoRow('Treatment Date', treatmentDate),
                          _buildInfoRow('Treatment Time', treatmentTime),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 0.5),

                  // Treatment Table
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Treatment',
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Price',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Male',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Female',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Total',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  ...treatments.map((t) {
                    final price = double.parse(t['price'].toString());
                    final count = (t['male'] as int) + (t['female'] as int);
                    final rowTotal = price * count;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text(t['name'])),
                          pw.Expanded(
                            child: pw.Text(
                              '₹${t['price']}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '${t['male']}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '${t['female']}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '₹${rowTotal.toInt()}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  pw.SizedBox(height: 10),
                  pw.Divider(thickness: 0.5),

                  // Totals
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildTotalRow('Total Amount', '₹${total.toInt()}'),
                          _buildTotalRow('Discount', '₹${discount.toInt()}'),
                          _buildTotalRow('Advance', '₹${advance.toInt()}'),
                          pw.SizedBox(height: 5),
                          pw.SizedBox(
                            width: 150,
                            child: pw.Divider(thickness: 0.5),
                          ),
                          _buildTotalRow(
                            'Balance',
                            '₹${balance.toInt()}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Thank you for choosing us',
                            style: pw.TextStyle(
                              color: PdfColors.green,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.SizedBox(
                            width: 250,
                            child: pw.Text(
                              'Your well-being is our commitment, and we\'re honored you\'ve entrusted us with your health journey',
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Image(sign, width: 80),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Thank you and Signature
                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 0.5),
                  pw.Center(
                    child: pw.Text(
                      '"Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment"',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Patient_Receipt_$name.pdf',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.Text(': $value', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.SizedBox(
            width: 50,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
