import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_style_tokens.dart';
import '../input_fields.dart';
import '../modal_header_row.dart';

class JobTimeSlotModal extends StatefulWidget {
  final JobTimeSlot? slot;
  final ValueChanged<JobTimeSlot> onSave;

  const JobTimeSlotModal({
    super.key,
    required this.slot,
    required this.onSave,
  });

  @override
  State<JobTimeSlotModal> createState() => _JobTimeSlotModalState();
}

class _JobTimeSlotModalState extends State<JobTimeSlotModal> {
  late String _timeOfDay;
  late TextEditingController _jobNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _timeOfDay = widget.slot?.timeOfDay ?? 'morning';
    _jobNameController =
        TextEditingController(text: widget.slot?.jobName ?? '');
    _startTimeController =
        TextEditingController(text: widget.slot?.startTime ?? '');
    _endTimeController =
        TextEditingController(text: widget.slot?.endTime ?? '');
    _notesController = TextEditingController(text: widget.slot?.notes ?? '');
  }

  @override
  void dispose() {
    _jobNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            primaryColor: AppColors.accent,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.modalSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _save() {
    if (_jobNameController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newSlot = JobTimeSlot(
      id: widget.slot?.id ?? '',
      jobName: _jobNameController.text,
      timeOfDay: _timeOfDay,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      notes: _notesController.text,
    );

    widget.onSave(newSlot);
  }

  String get _title =>
      widget.slot == null ? 'Add Job Time Slot' : 'Edit Job Time Slot';

  String get _actionLabel => widget.slot == null ? 'Add Slot' : 'Update Slot';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.modalSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModalHeaderRow(
                    title: _title,
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  _ModalFieldGroup(
                    label: 'Job Name',
                    child: InputFields(
                      controller: _jobNameController,
                      hintText: 'e.g., Job 1, Job 2',
                      hintColor: Colors.grey.shade500,
                      focusedBorderColor: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ModalFieldGroup(
                    label: 'Time of Day',
                    child: _TimeOfDaySelector(
                      selected: _timeOfDay,
                      onChanged: (value) {
                        setState(() {
                          _timeOfDay = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ModalFieldGroup(
                    label: 'Start Time',
                    child: _TimePickerField(
                      value: _startTimeController.text,
                      placeholder: 'Select start time',
                      onTap: () => _selectTime(context, _startTimeController),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ModalFieldGroup(
                    label: 'End Time',
                    child: _TimePickerField(
                      value: _endTimeController.text,
                      placeholder: 'Select end time',
                      onTap: () => _selectTime(context, _endTimeController),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ModalFieldGroup(
                    label: 'Notes (Optional)',
                    child: InputFields(
                      controller: _notesController,
                      maxLines: 3,
                      hintText: 'Add notes for this time slot',
                      hintColor: Colors.grey.shade500,
                      focusedBorderColor: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SaveSlotButton(label: _actionLabel, onPressed: _save),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModalFieldGroup extends StatelessWidget {
  const _ModalFieldGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  static const TextStyle _labelStyle = TextStyle(
    color: AppColors.label,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TimeOfDaySelector extends StatelessWidget {
  const _TimeOfDaySelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TimeOfDayOption(
              label: 'Morning',
              icon: Icons.wb_sunny,
              selected: selected == 'morning',
              onTap: () => onChanged('morning'),
            ),
          ),
          Expanded(
            child: _TimeOfDayOption(
              label: 'Evening',
              icon: Icons.nights_stay,
              selected: selected == 'evening',
              onTap: () => onChanged('evening'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeOfDayOption extends StatelessWidget {
  const _TimeOfDayOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.label),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEmpty ? placeholder : value,
                style: TextStyle(
                  color: isEmpty ? Colors.grey[500] : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveSlotButton extends StatelessWidget {
  const _SaveSlotButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
