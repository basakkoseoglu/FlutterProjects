import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/core/enums/work_type.dart';
import 'package:workdayapp/viewmodels/attendance_viewmodel.dart';
import 'package:workdayapp/views/attendance/daily_attendance_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime currentMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
     final viewModel = context.watch<AttendanceViewModel>();

     final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
    body: Column(
        children: [
          _MonthHeader(
            date: currentMonth,
            onChanged: (newDate) {
              setState(() {
                currentMonth = newDate;
              });
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                  day,
                );

                final workType = viewModel.getWorkTypeForDate(date);

                return GestureDetector(
                  onTap: () {
                _showDayDetailBottomSheet(context, date);
              },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorForWorkType(workType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForWorkType(WorkType? type) {
    switch (type) {
      case WorkType.fullDay:
        return Colors.green.withOpacity(0.3);
      case WorkType.halfDay:
        return Colors.orange.withOpacity(0.3);
      case WorkType.leave:
        return Colors.red.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _MonthHeader({
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onChanged(DateTime(date.year, date.month - 1));
            },
          ),
          Text(
            '${date.month}.${date.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              onChanged(DateTime(date.year, date.month + 1));
            },
          ),
        ],
      ),
    );
  }
}

void _showDayDetailBottomSheet(BuildContext context, DateTime date) {
  final viewModel = Provider.of<AttendanceViewModel>(context, listen: false);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}.${date.month}.${date.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Durum: ${viewModel.getStatusTextForDate(date)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); 
                  
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: DailyAttendanceView(initialDate: date),
                      ),
                    ),
                  );
                  
                },
                child: const Text('Bu Günü Düzenle'),
              ),
            ),
          ],
        ),
      );
    },
  );
}