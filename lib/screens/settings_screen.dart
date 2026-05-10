import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_style_tokens.dart';
import '../services/firestore_service.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/settings/job_time_slot_modal.dart';
import '../widgets/settings/job_time_slots_section.dart';
import '../widgets/settings/settings_logout_section.dart';
import '../widgets/settings/settings_top_header_section.dart';

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
      backgroundColor: AppColors.background,
      body: AppGradientScreenShell(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SettingsTopHeaderSection(
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
              SettingsLogoutSection(
                onLogoutPressed: () => _logout(context),
              ),
              const SizedBox(height: 24),
            ],
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
      builder: (context) => JobTimeSlotModal(
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

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
