import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/viewmodels/attendance_viewmodel.dart';

class DailyAttendanceView extends StatelessWidget {
  final DateTime? initialDate;
  const DailyAttendanceView({super.key, this.initialDate});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();

    if (initialDate != null &&
        !_isSameDay(viewModel.selectedDate, initialDate!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.selectDate(initialDate!);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Kayıt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //tarih
            Text('Tarih', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: viewModel.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  viewModel.selectDate(pickedDate);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${viewModel.selectedDate.day}.${viewModel.selectedDate.month}.${viewModel.selectedDate.year}',
                ),
              ),
            ),

            const SizedBox(height: 24),

            //çalışma türü seçenekleri
            const Text(
              'Çalışma Türü',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            //tam gün
            _WorkTypeTile(
              title: 'Tam Gün',
              selected: viewModel.selectedWorkType == WorkType.fullDay,
              onTap: () => viewModel.selectWorkType(WorkType.fullDay),
            ),
            _WorkTypeTile(
              title: 'Yarım Gün',
              selected: viewModel.selectedWorkType == WorkType.halfDay,
              onTap: () => viewModel.selectWorkType(WorkType.halfDay),
            ),
            _WorkTypeTile(
              title: 'İzin',
              selected: viewModel.selectedWorkType == WorkType.leave,
              onTap: () => viewModel.selectWorkType(WorkType.leave),
            ),

            //kaydet butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.selectedWorkType == null
                    ? null
                    : () async {
                        await viewModel.saveAttendance();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: const Text('Kaydet'),
              ),
            ),

            if (viewModel.selectedWorkType != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () async {
                    await context
                        .read<AttendanceViewModel>()
                        .deleteAttendanceForSelectedDate();
                  },
                  child: const Text('Günü Temizle'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WorkTypeTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _WorkTypeTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.indigo.shade100 : null,
          border: Border.all(color: selected ? Colors.indigo : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title),
      ),
    );
  }
}
