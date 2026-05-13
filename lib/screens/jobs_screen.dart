import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_style_tokens.dart';
import '../services/firestore_service.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/settings/job_time_slot_modal.dart';
import '../widgets/settings/job_time_slots_section.dart';
import '../widgets/settings/settings_top_header_section.dart';

class JobsManagementScreen extends StatefulWidget {
  const JobsManagementScreen({
    super.key,
    this.isDayTheme = false,
  });

  final bool isDayTheme;

  @override
  State<JobsManagementScreen> createState() => _JobsManagementScreenState();
}

class _JobsManagementScreenState extends State<JobsManagementScreen> {
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppScreenPalette.fromIsDay(widget.isDayTheme);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: palette.background,
        body: AppGradientScreenShell(
          gradient: palette.gradient,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SettingsTopHeaderSection(
                  title: 'Manage Your Jobs',
                  textColor: palette.primaryText,
                  onBackPressed: () => Navigator.pop(context),
                ),
                StreamBuilder<List<JobTimeSlot>>(
                  stream: _firestoreService.getJobTimeSlots(),
                  builder: (context, snapshot) {
                    return JobTimeSlotsSection(
                      snapshot: snapshot,
                      palette: palette,
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
      ),
    );
  }

  void _showJobTimeSlotModal(BuildContext context, {JobTimeSlot? slot}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => JobTimeSlotModal(
        slot: slot,
        palette: AppScreenPalette.fromIsDay(widget.isDayTheme),
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
    final palette = AppScreenPalette.fromIsDay(widget.isDayTheme);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job?'),
        backgroundColor: palette.modalSurface,
        titleTextStyle: TextStyle(
          color: palette.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: palette.secondaryText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: palette.accent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: palette.destructive),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteJobTimeSlot(slotId);
    }
  }
}
