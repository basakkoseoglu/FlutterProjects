import 'package:flutter/material.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';

class SalarySettingsDialog extends StatelessWidget {
  final AttendanceViewModel viewModel;

  const SalarySettingsDialog({
    super.key,
    required this.viewModel,
  });

  static void show(BuildContext context, AttendanceViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => SalarySettingsDialog(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyWageController = TextEditingController(
      text: viewModel.salarySettings.dailyWage.toString(),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Maaş Ayarları'),
      content: TextField(
        controller: dailyWageController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Günlük Ücret (₺)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final dailyWage = double.tryParse(dailyWageController.text) ?? 0;

            await viewModel.updateSalarySettings(dailyWage: dailyWage);

            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}