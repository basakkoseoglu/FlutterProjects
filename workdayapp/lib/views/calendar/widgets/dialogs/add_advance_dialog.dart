import 'package:flutter/material.dart';
import 'package:workdayapp/viewmodels/attendance/attendance_viewmodel.dart';

class AddAdvanceDialog extends StatelessWidget {
  final AttendanceViewModel viewModel;

  const AddAdvanceDialog({
    super.key,
    required this.viewModel,
  });

  static void show(BuildContext context, AttendanceViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AddAdvanceDialog(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('Avans Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Avans Tutarı (₺)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Not (opsiyonel)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 0;

            if (amount > 0) {
              viewModel.addAdvance(
                amount,
                DateTime.now(),
                note: noteController.text,
              );
            }

            Navigator.pop(context);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}