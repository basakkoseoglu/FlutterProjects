import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workdayapp/models/attendance.dart';
import 'package:workdayapp/core/enums/work_type.dart';

class PdfReportService {
  Future<File> generateMonthlyReport({
    required List<Attendance> attendances,
    required int month,
    required int year,
  }) async {
    final pdf = pw.Document();

    final monthlyData = attendances
        .where((a) => a.date.month == month && a.date.year == year)
        .toList()
      ..sort((a, b) => a.date.day.compareTo(b.date.day));

    final full =
        monthlyData.where((a) => a.workType == WorkType.fullDay).length;
    final half =
        monthlyData.where((a) => a.workType == WorkType.halfDay).length;
    final leave =
        monthlyData.where((a) => a.workType == WorkType.leave).length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Aylik Puantaj Raporu',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text('$month / $year'),
              pw.Divider(),

              pw.Text(
                'Özet',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Tam Gün: $full'),
              pw.Text('Yarım Gün: $half'),
              pw.Text('İzin: $leave'),

              pw.SizedBox(height: 16),

              pw.Text(
                'Günlük Kayıtlar',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      _headerCell('Tarih'),
                      _headerCell('Durum'),
                    ],
                  ),
                  ...monthlyData.map(
                    (a) => pw.TableRow(
                      children: [
                        _cell(
                          '${a.date.day}.${a.date.month}.${a.date.year}',
                        ),
                        _cell(_workTypeText(a.workType)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/puantaj_${month}_$year.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  String _workTypeText(WorkType type) {
    switch (type) {
      case WorkType.fullDay:
        return 'Tam Gün';
      case WorkType.halfDay:
        return 'Yarım Gün';
      case WorkType.leave:
        return 'İzin';
    }
  }
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _cell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(text),
  );
}
