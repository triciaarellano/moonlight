import 'dart:async';

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

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
  String _createType = 'schedule';

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
            primaryColor: const Color(0xFF7C5FDD),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C5FDD),
              surface: Color(0xFF2D1265),
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
            primaryColor: const Color(0xFF7C5FDD),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C5FDD),
              surface: Color(0xFF2D1265),
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
            primaryColor: const Color(0xFF7C5FDD),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C5FDD),
              surface: Color(0xFF2D1265),
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
        if (_createType == 'schedule') {
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
                  '${_createType == 'schedule' ? 'Schedule' : 'Note'} created successfully!'),
              backgroundColor: const Color(0xFF7C5FDD),
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
          color: Color(0xFF2D1265),
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C0A4A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF7C5FDD).withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _createType = 'schedule';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: _createType == 'schedule'
                                      ? const Color(0xFF7C5FDD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: _createType == 'schedule'
                                          ? Colors.white
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Schedule',
                                      style: TextStyle(
                                        color: _createType == 'schedule'
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: _createType == 'schedule'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _createType = 'note';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: _createType == 'note'
                                      ? const Color(0xFF7C5FDD)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.note,
                                      color: _createType == 'note'
                                          ? Colors.white
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Note',
                                      style: TextStyle(
                                        color: _createType == 'note'
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: _createType == 'note'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Field (both schedule and note)
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                        hintText: _createType == 'schedule'
                            ? 'Enter schedule title'
                            : 'Enter note title',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF7C5FDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFB5A957)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1C0A4A),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_jobNames.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C0A4A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF7C5FDD)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFFB5A957),
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
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _selectedJobName,
                        dropdownColor: const Color(0xFF1C0A4A),
                        iconEnabledColor: const Color(0xFFB5A957),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Job',
                          labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF7C5FDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFB5A957)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C0A4A),
                        ),
                        items: _jobNames
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
                        onChanged: (value) {
                          setState(() {
                            _selectedJobName = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a job';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),

                    // Schedule-specific fields
                    if (_createType == 'schedule') ...[
                      // Date Field
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF7C5FDD)),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF1C0A4A),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFFB5A957)),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate.toString().split(' ')[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Note-specific fields
                    if (_createType == 'note') ...[
                      TextFormField(
                        controller: _contentController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                          hintText: 'Enter note content',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF7C5FDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFB5A957)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C0A4A),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Field for Note
                      GestureDetector(
                        onTap: () => _selectNoteDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF7C5FDD)),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF1C0A4A),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFFB5A957)),
                              const SizedBox(width: 12),
                              Text(
                                _noteSelectedDate != null
                                    ? _noteSelectedDate.toString().split(' ')[0]
                                    : 'Select date (optional)',
                                style: TextStyle(
                                  color: _noteSelectedDate != null
                                      ? Colors.white
                                      : Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Time Field for Note
                      TextFormField(
                        controller: _noteTimeController,
                        readOnly: true,
                        onTap: () => _selectNoteTime(context),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                          hintText: 'Select time (optional)',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: const Icon(Icons.access_time,
                              color: Color(0xFFB5A957)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF7C5FDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFB5A957)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C0A4A),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Place Field (schedule only)
                    if (_createType == 'schedule')
                      TextFormField(
                        controller: _placeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Place',
                          labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                          hintText: 'Enter location',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: const Icon(Icons.location_on,
                              color: Color(0xFFB5A957)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF7C5FDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFB5A957)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C0A4A),
                        ),
                      ),
                    if (_createType == 'schedule') const SizedBox(height: 16),

                    // Notes Field (schedule only)
                    if (_createType == 'schedule')
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          labelStyle: const TextStyle(color: Color(0xFFB5A957)),
                          hintText: 'Add any notes',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF7C5FDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFB5A957)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1C0A4A),
                        ),
                      ),
                    if (_createType == 'schedule') const SizedBox(height: 16),

                    // Completed Checkbox (schedule only)
                    if (_createType == 'schedule')
                      Row(
                        children: [
                          Checkbox(
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value ?? false;
                              });
                            },
                            fillColor: WidgetStateProperty.all(
                                const Color(0xFF7C5FDD)),
                          ),
                          const Text(
                            'Mark as completed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C5FDD),
                          disabledBackgroundColor:
                              const Color(0xFF7C5FDD).withValues(alpha: 0.6),
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
                                'Create ${_createType == 'schedule' ? 'Schedule' : 'Note'}',
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
