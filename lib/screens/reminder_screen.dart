import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import 'package:uuid/uuid.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminders'),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return ListTile(
            title: Text(reminder.medicationName),
            subtitle: Text(
              '${reminder.quantity} pills at ${reminder.time.format(context)} - ${_getDaysText(reminder.days)}',
            ),
            trailing: Switch(
              value: reminder.isActive,
              onChanged: (value) {
                ref.read(reminderProvider.notifier).toggleReminder(reminder.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => Consumer(
            builder: (context, ref, child) => const AddReminderDialog(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDaysText(List<int> days) {
    if (days.isEmpty) return 'No days selected';
    if (days.length == 7) return 'Every day';

    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days.map((day) => dayNames[day]).join(', ');
  }
}

class AddReminderDialog extends ConsumerStatefulWidget {
  const AddReminderDialog({super.key});

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
  final _medicationController = TextEditingController();
  final _quantityController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<int> _selectedDays = [];

  @override
  void dispose() {
    _medicationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _medicationController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Time'),
              trailing: Text(_selectedTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              
              children: List.generate(7, (index) {
                final dayNames = [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat'
                ];
                final isSelected = _selectedDays.contains(index);
                return ChoiceChip(
                  label: Text(dayNames[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(index);
                      } else {
                        _selectedDays.remove(index);
                      }
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_medicationController.text.isNotEmpty &&
                _quantityController.text.isNotEmpty &&
                _selectedDays.isNotEmpty) {
              final uuid = const Uuid();
              ref.read(reminderProvider.notifier).addReminder(
                    Reminder(
                      id: uuid.v4(),
                      medicationName: _medicationController.text,
                      quantity: int.parse(_quantityController.text),
                      time: _selectedTime,
                      days: _selectedDays,
                    ),
                  );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
