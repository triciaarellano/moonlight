import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_style_tokens.dart';
import '../input_fields.dart';
import '../modal_header_row.dart';

class JobTimeSlotModal extends StatefulWidget {
  final JobTimeSlot? slot;
  final ValueChanged<JobTimeSlot> onSave;
  final AppScreenPalette? palette;

  const JobTimeSlotModal({
    super.key,
    required this.slot,
    required this.onSave,
    this.palette,
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
    final palette = widget.palette ?? AppScreenPalette.night();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final colorScheme = palette.isDay
            ? ColorScheme.light(
                primary: palette.accent,
                surface: palette.modalSurface,
                onSurface: palette.primaryText,
              )
            : ColorScheme.dark(
                primary: palette.accent,
                surface: palette.modalSurface,
                onSurface: palette.primaryText,
              );

        return Theme(
          data: (palette.isDay ? ThemeData.light() : ThemeData.dark()).copyWith(
            primaryColor: palette.accent,
            colorScheme: colorScheme,
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
    final palette = widget.palette ?? AppScreenPalette.night();

    if (_jobNameController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: palette.destructive,
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
    final palette = widget.palette ?? AppScreenPalette.night();
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: palette.modalSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: mediaQuery.size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ModalFormContent(
                title: _title,
                actionLabel: _actionLabel,
                palette: palette,
                timeOfDay: _timeOfDay,
                jobNameController: _jobNameController,
                startTimeController: _startTimeController,
                endTimeController: _endTimeController,
                notesController: _notesController,
                onClose: () => Navigator.pop(context),
                onSave: _save,
                onTimeOfDayChanged: (value) {
                  setState(() {
                    _timeOfDay = value;
                  });
                },
                onSelectStartTime: () =>
                    _selectTime(context, _startTimeController),
                onSelectEndTime: () =>
                    _selectTime(context, _endTimeController),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalFormContent extends StatelessWidget {
  const _ModalFormContent({
    required this.title,
    required this.actionLabel,
    required this.palette,
    required this.timeOfDay,
    required this.jobNameController,
    required this.startTimeController,
    required this.endTimeController,
    required this.notesController,
    required this.onClose,
    required this.onSave,
    required this.onTimeOfDayChanged,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
  });

  final String title;
  final String actionLabel;
  final AppScreenPalette palette;
  final String timeOfDay;
  final TextEditingController jobNameController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController notesController;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final ValueChanged<String> onTimeOfDayChanged;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeaderRow(
          title: title,
          titleStyle: TextStyle(
            color: palette.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconColor: palette.primaryText,
          onClose: onClose,
        ),
        const SizedBox(height: 12),
        _ModalFieldGroup(
          label: 'Job Name',
          palette: palette,
          child: InputFields(
            controller: jobNameController,
            hintText: 'e.g., Job 1, Job 2',
            textColor: palette.primaryText,
            hintColor: palette.mutedText,
            fillColor: palette.surface,
            borderColor: palette.cardBorder,
            focusedBorderColor: palette.accent,
          ),
        ),
        const SizedBox(height: 12),
        _ModalFieldGroup(
          label: 'Time of Day',
          palette: palette,
          child: _TimeOfDaySelector(
            selected: timeOfDay,
            palette: palette,
            onChanged: onTimeOfDayChanged,
          ),
        ),
        const SizedBox(height: 12),
        _ModalFieldGroup(
          label: 'Start Time',
          palette: palette,
          child: _TimePickerField(
            value: startTimeController.text,
            placeholder: 'Select start time',
            palette: palette,
            onTap: onSelectStartTime,
          ),
        ),
        const SizedBox(height: 12),
        _ModalFieldGroup(
          label: 'End Time',
          palette: palette,
          child: _TimePickerField(
            value: endTimeController.text,
            placeholder: 'Select end time',
            palette: palette,
            onTap: onSelectEndTime,
          ),
        ),
        const SizedBox(height: 12),
        _ModalFieldGroup(
          label: 'Notes (Optional)',
          palette: palette,
          child: InputFields(
            controller: notesController,
            maxLines: 3,
            hintText: 'Add notes for this time slot',
            textColor: palette.primaryText,
            hintColor: palette.mutedText,
            fillColor: palette.surface,
            borderColor: palette.cardBorder,
            focusedBorderColor: palette.accent,
          ),
        ),
        const SizedBox(height: 20),
        _SaveSlotButton(
          label: actionLabel,
          palette: palette,
          onPressed: onSave,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ModalFieldGroup extends StatelessWidget {
  const _ModalFieldGroup({
    required this.label,
    required this.palette,
    required this.child,
  });

  final String label;
  final AppScreenPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.accentText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TimeOfDaySelector extends StatelessWidget {
  const _TimeOfDaySelector({
    required this.selected,
    required this.palette,
    required this.onChanged,
  });

  final String selected;
  final AppScreenPalette palette;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.cardBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TimeOfDayOption(
              label: 'Morning',
              icon: Icons.wb_sunny,
              selected: selected == 'morning',
              palette: palette,
              onTap: () => onChanged('morning'),
            ),
          ),
          Expanded(
            child: _TimeOfDayOption(
              label: 'Evening',
              icon: Icons.nights_stay,
              selected: selected == 'evening',
              palette: palette,
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
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final AppScreenPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? palette.onAccent : palette.mutedText,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? palette.onAccent : palette.mutedText,
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
    required this.palette,
    required this.onTap,
  });

  final String value;
  final String placeholder;
  final AppScreenPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: palette.cardBorder),
          borderRadius: BorderRadius.circular(8),
          color: palette.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: palette.accentText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEmpty ? placeholder : value,
                style: TextStyle(
                  color: isEmpty ? palette.mutedText : palette.primaryText,
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
  const _SaveSlotButton({
    required this.label,
    required this.palette,
    required this.onPressed,
  });

  final String label;
  final AppScreenPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
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
