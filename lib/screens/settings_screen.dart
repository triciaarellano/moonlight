import 'package:flutter/material.dart';
import '../theme/app_style_tokens.dart';
import '../services/firestore_service.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/settings/job_time_slot_modal.dart';
import '../widgets/settings/job_time_slots_section.dart';
import '../widgets/settings/settings_top_header_section.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientScreenShell(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SettingsTopHeaderSection(
                title: 'Manage Your Jobs',
                onBackPressed: () => Navigator.pop(context),
              ),
              StreamBuilder<List<JobTimeSlot>>(
                stream: _firestoreService.getJobTimeSlots(),
                builder: (context, snapshot) {
                  return JobTimeSlotsSection(
                    snapshot: snapshot,
                    onAddPressed: () => _showJobTimeSlotModal(context),
                    onEdit: (slot) =>
                        _showJobTimeSlotModal(context, slot: slot),
                    onDelete: (slot) => _deleteJobTimeSlot(slot.id),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobTimeSlotModal(BuildContext context, {JobTimeSlot? slot}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => JobTimeSlotModal(
        slot: slot,
        onSave: (newSlot) {
          if (slot == null) {
            _firestoreService.addJobTimeSlot(newSlot);
          } else {
            _firestoreService.updateJobTimeSlot(newSlot);
          }
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  Future<void> _deleteJobTimeSlot(String slotId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        backgroundColor: AppColors.modalSurface,
        titleTextStyle: const TextStyle(color: Colors.white),
        contentTextStyle: const TextStyle(color: Colors.white70),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.accent)),
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
}
