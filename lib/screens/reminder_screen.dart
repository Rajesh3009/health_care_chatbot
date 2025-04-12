import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder.dart';
import 'package:uuid/uuid.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminders'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   child: ElevatedButton.icon(
          //     onPressed: () async {
          //       await NotificationService().showTestNotification(context);
          //     },
          //     icon: const Icon(Icons.notifications_active),
          //     label: const Text('Test Notification'),
          //     style: ElevatedButton.styleFrom(
          //       padding:
          //           const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: reminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reminders set',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a reminder',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            reminder.medicationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${reminder.quantity} pills at ${reminder.time.format(context)}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getDaysText(reminder.days),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => Consumer(
                              builder: (context, ref, child) =>
                                  EditReminderDialog(reminder: reminder),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: reminder.isActive,
                                onChanged: (value) {
                                  ref
                                      .read(reminderProvider.notifier)
                                      .toggleReminder(reminder.id, context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Reminder'),
                                      content: const Text(
                                          'Are you sure you want to delete this reminder?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(reminderProvider.notifier)
                                                .deleteReminder(reminder.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => Consumer(
            builder: (context, ref, child) => const AddReminderDialog(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  String _getDaysText(List<int> days) {
    if (days.isEmpty) return 'No days selected';
    if (days.length == 7) return 'Every day';

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days.map((day) => dayNames[day]).join(', ');
  }
}

class AddReminderDialog extends ConsumerStatefulWidget {
  const AddReminderDialog({super.key});

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class EditReminderDialog extends ConsumerStatefulWidget {
  final Reminder reminder;
  const EditReminderDialog({super.key, required this.reminder});

  @override
  ConsumerState<EditReminderDialog> createState() => _EditReminderDialogState();
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
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ];
                final isSelected = _selectedDays.contains(index);
                return SizedBox(
                  width: 100,
                  child: ChoiceChip(
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
                  ),
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
                  context);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditReminderDialogState extends ConsumerState<EditReminderDialog> {
  late final TextEditingController _medicationController;
  late final TextEditingController _quantityController;
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _medicationController =
        TextEditingController(text: widget.reminder.medicationName);
    _quantityController =
        TextEditingController(text: widget.reminder.quantity.toString());
    _selectedTime = widget.reminder.time;
    _selectedDays = List.from(widget.reminder.days);
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Medication Reminder'),
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
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ];
                final isSelected = _selectedDays.contains(index);
                return SizedBox(
                  width: 100,
                  child: ChoiceChip(
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
                  ),
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
              ref.read(reminderProvider.notifier).updateReminder(
                  Reminder(
                    id: widget.reminder.id,
                    medicationName: _medicationController.text,
                    quantity: int.parse(_quantityController.text),
                    time: _selectedTime,
                    days: _selectedDays,
                    isActive: widget.reminder.isActive,
                  ),
                  context);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
