import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:workdayapp/models/attendance.dart';
import 'package:workdayapp/core/enums/work_type.dart';

class PdfReportService {
  Future<void> generateMonthlyReport({
    required List<Attendance> attendances,
    required int month,
    required int year,
  }) async {
    final pdf = pw.Document();

    final monthlyData = attendances
        .where((a) => a.date.month == month && a.date.year == year)
        .toList();

    final full =
        monthlyData.where((a) => a.workType == WorkType.fullDay).length;
    final half =
        monthlyData.where((a) => a.workType == WorkType.halfDay).length;
    final leave =
        monthlyData.where((a) => a.workType == WorkType.leave).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(month, year),
          pw.SizedBox(height: 16),
          _buildSummary(full, half, leave),
          pw.SizedBox(height: 24),
          _buildTable(monthlyData),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/puantaj_${month}_$year.pdf');

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(int month, int year) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Aylık Puantaj Raporu',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('$month / $year'),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildSummary(int full, int half, int leave) {
    pw.Widget box(String title, int value, PdfColor color) {
      return pw.Container(
        width: 120,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(title,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
              value.toString(),
              style: const pw.TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        box('Tam Gün', full, PdfColors.green100),
        box('Yarim Gün', half, PdfColors.orange100),
        box('Izin', leave, PdfColors.red100),
      ],
    );
  }

  pw.Widget _buildTable(List<Attendance> data) {
    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Tarih', 'Gün', 'Durum'],
      data: data.map((a) {
        return [
          '${a.date.day}.${a.date.month}.${a.date.year}',
          _dayName(a.date),
          _workTypeText(a.workType),
        ];
      }).toList(),
    );
  }

  String _dayName(DateTime date) {
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return days[date.weekday - 1];
  }

  String _workTypeText(WorkType type) {
    switch (type) {
      case WorkType.fullDay:
        return 'Tam Gün';
      case WorkType.halfDay:
        return 'Yarim Gün';
      case WorkType.leave:
        return 'Izin';
    }
  }
}
