import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/input_fields.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1C0A4A),
                Color(0xFF0A0118),
                Color(0xFF2D1265),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Time Slots Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Job Time Slots',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showJobTimeSlotModal(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C5FDD),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<JobTimeSlot>>(
                          stream: _firestoreService.getJobTimeSlots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Color(0xFF7C5FDD)),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              );
                            }

                            final slots = snapshot.data ?? [];

                            if (slots.isEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFF3D1E6F)
                                      .withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: const Color(0xFF7C5FDD)
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Center(
                                  child: Text(
                                    'No job time slots configured yet',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: slots.map((slot) {
                                return _JobTimeSlotCard(
                                  slot: slot,
                                  onEdit: () => _showJobTimeSlotModal(context,
                                      slot: slot),
                                  onDelete: () => _deleteJobTimeSlot(slot.id),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showJobTimeSlotModal(BuildContext context, {JobTimeSlot? slot}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _JobTimeSlotModal(
        slot: slot,
        onSave: (newSlot) {
          if (slot == null) {
            _firestoreService.addJobTimeSlot(newSlot);
          } else {
            _firestoreService.updateJobTimeSlot(newSlot);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _deleteJobTimeSlot(String slotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job Time Slot'),
        content: const Text('Are you sure you want to delete this slot?'),
        backgroundColor: const Color(0xFF2D1265),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF7C5FDD))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteJobTimeSlot(slotId);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        backgroundColor: const Color(0xFF2D1265),
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF7C5FDD))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }
}

class _JobTimeSlotCard extends StatelessWidget {
  final JobTimeSlot slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JobTimeSlotCard({
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF3D1E6F).withValues(alpha: 0.7),
        border: Border.all(
          color: const Color(0xFF7C5FDD).withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.jobName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        slot.timeOfDay == 'morning'
                            ? Icons.wb_sunny
                            : Icons.nights_stay,
                        color: slot.timeOfDay == 'morning'
                            ? Colors.amber[300]
                            : Colors.indigo[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slot.timeOfDay.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: onEdit,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          if (slot.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              slot.notes,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _JobTimeSlotModal extends StatefulWidget {
  final JobTimeSlot? slot;
  final Function(JobTimeSlot) onSave;

  const _JobTimeSlotModal({
    required this.slot,
    required this.onSave,
  });

  @override
  State<_JobTimeSlotModal> createState() => _JobTimeSlotModalState();
}

class _JobTimeSlotModalState extends State<_JobTimeSlotModal> {
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
      BuildContext context, TextEditingController controller) async {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D1265),
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.slot == null
                            ? 'Add Job Time Slot'
                            : 'Edit Job Time Slot',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Job Name Field
                  const Text(
                    'Job Name',
                    style: TextStyle(
                      color: Color(0xFFB5A957),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InputFields(
                    controller: _jobNameController,
                    hintText: 'e.g., Job 1, Job 2',
                    hintColor: Colors.grey.shade500,
                    focusedBorderColor: const Color(0xFFB5A957),
                  ),
                  const SizedBox(height: 16),

                  // Time of Day Selection
                  const Text(
                    'Time of Day',
                    style: TextStyle(
                      color: Color(0xFFB5A957),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                _timeOfDay = 'morning';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _timeOfDay == 'morning'
                                    ? const Color(0xFF7C5FDD)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wb_sunny,
                                    color: _timeOfDay == 'morning'
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Morning',
                                    style: TextStyle(
                                      color: _timeOfDay == 'morning'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: _timeOfDay == 'morning'
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
                                _timeOfDay = 'evening';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _timeOfDay == 'evening'
                                    ? const Color(0xFF7C5FDD)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.nights_stay,
                                    color: _timeOfDay == 'evening'
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Evening',
                                    style: TextStyle(
                                      color: _timeOfDay == 'evening'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: _timeOfDay == 'evening'
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
                  const SizedBox(height: 16),

                  // Start Time
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      color: Color(0xFFB5A957),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(context, _startTimeController),
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
                          const Icon(Icons.access_time,
                              color: Color(0xFFB5A957)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startTimeController.text.isEmpty
                                  ? 'Select start time'
                                  : _startTimeController.text,
                              style: TextStyle(
                                color: _startTimeController.text.isEmpty
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // End Time
                  const Text(
                    'End Time',
                    style: TextStyle(
                      color: Color(0xFFB5A957),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(context, _endTimeController),
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
                          const Icon(Icons.access_time,
                              color: Color(0xFFB5A957)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _endTimeController.text.isEmpty
                                  ? 'Select end time'
                                  : _endTimeController.text,
                              style: TextStyle(
                                color: _endTimeController.text.isEmpty
                                    ? Colors.grey[500]
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  const Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      color: Color(0xFFB5A957),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InputFields(
                    controller: _notesController,
                    maxLines: 3,
                    hintText: 'Add notes for this time slot',
                    hintColor: Colors.grey.shade500,
                    focusedBorderColor: const Color(0xFFB5A957),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5FDD),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.slot == null ? 'Add Slot' : 'Update Slot',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
