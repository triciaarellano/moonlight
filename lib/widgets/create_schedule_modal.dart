import 'dart:async';

import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../theme/app_style_tokens.dart';
import 'modal_header_row.dart';

const String _scheduleCreateType = 'schedule';
const String _noteCreateType = 'note';

class CreateScheduleModal extends StatefulWidget {
  const CreateScheduleModal({super.key});

  @override
  State<CreateScheduleModal> createState() => _CreateScheduleModalState();
}

class _CreateScheduleModalState extends State<CreateScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _notesController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteTimeController = TextEditingController();
  late final FirestoreService _firestoreService;
  StreamSubscription<List<JobTimeSlot>>? _jobTimeSlotSubscription;
  late DateTime _selectedDate;
  DateTime? _noteSelectedDate;
  List<String> _jobNames = <String>[];
  String? _selectedJobName;
  bool _isCompleted = false;
  bool _isLoading = false;
  String _createType = _scheduleCreateType;

  bool get _isSchedule => _createType == _scheduleCreateType;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _selectedDate = DateTime.now();
    _jobTimeSlotSubscription = _firestoreService.getJobTimeSlots().listen((
      slots,
    ) {
      final jobNames = slots
          .map((slot) => slot.jobName.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (!mounted) {
        return;
      }

      setState(() {
        _jobNames = jobNames;

        if (_selectedJobName != null && !_jobNames.contains(_selectedJobName)) {
          _selectedJobName = null;
        }

        if (_selectedJobName == null && _jobNames.isNotEmpty) {
          _selectedJobName = _jobNames.first;
        }
      });
    });
  }

  @override
  void dispose() {
    _jobTimeSlotSubscription?.cancel();
    _titleController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    _contentController.dispose();
    _noteTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectNoteDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _noteSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
        _noteSelectedDate = picked;
      });
    }
  }

  Future<void> _selectNoteTime(BuildContext context) async {
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
        _noteTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _create() async {
    if (_jobNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a job in Settings first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedJobName = _selectedJobName;
    if (selectedJobName == null || selectedJobName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isSchedule) {
          final scheduleItem = ScheduleItem(
            id: '',
            day: _selectedDate.day,
            jobName: selectedJobName,
            title: _titleController.text,
            place: _placeController.text,
            notes: _notesController.text,
            isCompleted: _isCompleted,
          );

          await _firestoreService.addScheduleItem(scheduleItem);
        } else {
          final note = Note(
            id: '',
            jobName: selectedJobName,
            title: _titleController.text,
            content: _contentController.text,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            noteDate: _noteSelectedDate,
            noteTime: _noteTimeController.text.isEmpty
                ? null
                : _noteTimeController.text,
          );

          await _firestoreService.addNote(note);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "${_isSchedule ? 'Schedule' : 'Note'} created successfully!"),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.modalSurface,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModalHeaderRow(
                      title: 'Create',
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 16),
                    _CreateTypeSegmentedSelector(
                      selectedType: _createType,
                      onTypeSelected: (type) {
                        if (type == _createType) {
                          return;
                        }
                        setState(() {
                          _createType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _SharedTitleJobFieldsBlock(
                      createType: _createType,
                      titleController: _titleController,
                      jobNames: _jobNames,
                      selectedJobName: _selectedJobName,
                      onJobChanged: (value) {
                        setState(() {
                          _selectedJobName = value;
                        });
                      },
                    ),
                    if (_isSchedule)
                      _ScheduleFieldsBlock(
                        selectedDate: _selectedDate,
                        onDateTap: () => _selectDate(context),
                        placeController: _placeController,
                        notesController: _notesController,
                        isCompleted: _isCompleted,
                        onCompletedChanged: (value) {
                          setState(() {
                            _isCompleted = value;
                          });
                        },
                      ),
                    if (!_isSchedule)
                      _NoteFieldsBlock(
                        contentController: _contentController,
                        noteSelectedDate: _noteSelectedDate,
                        onDateTap: () => _selectNoteDate(context),
                        noteTimeController: _noteTimeController,
                        onTimeTap: () => _selectNoteTime(context),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor:
                              AppColors.accent.withValues(alpha: 0.6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                "Create ${_isSchedule ? 'Schedule' : 'Note'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateTypeSegmentedSelector extends StatelessWidget {
  const _CreateTypeSegmentedSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _CreateTypeSelectorOption(
              type: _scheduleCreateType,
              label: 'Schedule',
              icon: Icons.event,
              selectedType: selectedType,
              onTap: onTypeSelected,
            ),
          ),
          Expanded(
            child: _CreateTypeSelectorOption(
              type: _noteCreateType,
              label: 'Note',
              icon: Icons.note,
              selectedType: selectedType,
              onTap: onTypeSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTypeSelectorOption extends StatelessWidget {
  const _CreateTypeSelectorOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.selectedType,
    required this.onTap,
  });

  final String type;
  final String label;
  final IconData icon;
  final String selectedType;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedTitleJobFieldsBlock extends StatelessWidget {
  const _SharedTitleJobFieldsBlock({
    required this.createType,
    required this.titleController,
    required this.jobNames,
    required this.selectedJobName,
    required this.onJobChanged,
  });

  final String createType;
  final TextEditingController titleController;
  final List<String> jobNames;
  final String? selectedJobName;
  final ValueChanged<String?> onJobChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModalTextFormField(
          controller: titleController,
          labelText: 'Title',
          hintText: createType == _scheduleCreateType
              ? 'Enter schedule title'
              : 'Enter note title',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (jobNames.isEmpty)
          const _NoJobsInfoBanner()
        else
          DropdownButtonFormField<String>(
            initialValue: selectedJobName,
            dropdownColor: AppColors.surface,
            iconEnabledColor: AppColors.label,
            style: const TextStyle(color: Colors.white),
            decoration: _modalInputDecoration(labelText: 'Job'),
            items: jobNames
                .map(
                  (jobName) => DropdownMenuItem<String>(
                    value: jobName,
                    child: Text(
                      jobName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: onJobChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a job';
              }
              return null;
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NoJobsInfoBanner extends StatelessWidget {
  const _NoJobsInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.label,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No jobs found. Add a Job Time Slot in Settings first.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleFieldsBlock extends StatelessWidget {
  const _ScheduleFieldsBlock({
    required this.selectedDate,
    required this.onDateTap,
    required this.placeController,
    required this.notesController,
    required this.isCompleted,
    required this.onCompletedChanged,
  });

  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final TextEditingController placeController;
  final TextEditingController notesController;
  final bool isCompleted;
  final ValueChanged<bool> onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModalDateSelectorField(
          displayText: selectedDate.toString().split(' ')[0],
          onTap: onDateTap,
        ),
        const SizedBox(height: 16),
        _ModalTextFormField(
          controller: placeController,
          labelText: 'Place',
          hintText: 'Enter location',
          prefixIcon: const Icon(Icons.location_on, color: AppColors.label),
        ),
        const SizedBox(height: 16),
        _ModalTextFormField(
          controller: notesController,
          labelText: 'Notes',
          hintText: 'Add any notes',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (value) => onCompletedChanged(value ?? false),
              fillColor: WidgetStateProperty.all(AppColors.accent),
            ),
            const Text(
              'Mark as completed',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoteFieldsBlock extends StatelessWidget {
  const _NoteFieldsBlock({
    required this.contentController,
    required this.noteSelectedDate,
    required this.onDateTap,
    required this.noteTimeController,
    required this.onTimeTap,
  });

  final TextEditingController contentController;
  final DateTime? noteSelectedDate;
  final VoidCallback onDateTap;
  final TextEditingController noteTimeController;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModalTextFormField(
          controller: contentController,
          labelText: 'Content',
          hintText: 'Enter note content',
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter content';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _ModalDateSelectorField(
          displayText: noteSelectedDate != null
              ? noteSelectedDate.toString().split(' ')[0]
              : 'Select date (optional)',
          textColor:
              noteSelectedDate != null ? Colors.white : Colors.grey.shade500,
          onTap: onDateTap,
        ),
        const SizedBox(height: 16),
        _ModalTextFormField(
          controller: noteTimeController,
          labelText: 'Time',
          hintText: 'Select time (optional)',
          readOnly: true,
          onTap: onTimeTap,
          prefixIcon: const Icon(Icons.access_time, color: AppColors.label),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ModalTextFormField extends StatelessWidget {
  const _ModalTextFormField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: _modalInputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
    );
  }
}

class _ModalDateSelectorField extends StatelessWidget {
  const _ModalDateSelectorField({
    required this.displayText,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String displayText;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.calendar_today, color: AppColors.label),
            const SizedBox(width: 12),
            Text(
              displayText,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _modalInputDecoration({
  required String labelText,
  String? hintText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(color: AppColors.label),
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey.shade500),
    border: _modalInputBorder(AppColors.accent),
    focusedBorder: _modalInputBorder(AppColors.label),
    filled: true,
    fillColor: AppColors.surface,
    prefixIcon: prefixIcon,
  );
}

OutlineInputBorder _modalInputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}
