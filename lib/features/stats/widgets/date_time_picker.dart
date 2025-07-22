import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerRow extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const DateRangePickerRow({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  Future<void> _pickDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onDateChanged,
  ) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (newDate != null) {
      onDateChanged(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    return Row(
      children: [
        const Text('Du'),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(context, startDate, onStartDateChanged),
            child: Text(formatter.format(startDate)),
          ),
        ),
        const SizedBox(width: 8),
        const Text('au'),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(context, endDate, onEndDateChanged),
            child: Text(formatter.format(endDate)),
          ),
        ),
      ],
    );
  }
}
