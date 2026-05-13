import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/job_time_helper.dart';
import '../theme/app_style_tokens.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/common_top_header_row.dart';
import '../widgets/create_schedule_modal.dart';
import '../widgets/no_jobs_setup_card.dart';
import '../widgets/schedule_details_modal.dart';
import '../widgets/section_card.dart';
import '../widgets/tab_navigation_widget.dart';
import '../widgets/user_initials_logo_button.dart';
import 'jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  late DateTime _selectedDate;
  late FirestoreService _firestoreService;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firestoreService = FirestoreService();

    // Refresh the UI every minute to update active job filtering
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientScreenShell(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _HomeTopHeaderSection(
                displayName: FirebaseAuth.instance.currentUser?.displayName,
                onMenuPressed: () => _showMenu(context),
              ),
              _HomeTabAndContentSection(
                selectedTabIndex: _selectedTabIndex,
                selectedDate: _selectedDate,
                firestoreService: _firestoreService,
                onTabSelected: (index) =>
                    setState(() => _selectedTabIndex = index),
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: _HomeAddScheduleFab(
        onPressed: () => _showCreateScheduleDialog(context),
      ),
    );
  }

  void _showCreateScheduleDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: const CreateScheduleModal(),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.modalSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _HomeMenuSheet(
        onManageJobsPressed: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            sheetContext,
            MaterialPageRoute(
                builder: (context) => const JobsManagementScreen()),
          );
        },
        onLogoutPressed: () {
          Navigator.pop(sheetContext);
          FirebaseAuth.instance.signOut();
        },
      ),
    );
  }
}

class _HomeTopHeaderSection extends StatelessWidget {
  const _HomeTopHeaderSection({
    required this.displayName,
    required this.onMenuPressed,
  });

  final String? displayName;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return CommonTopHeaderRow(
      title: 'moonlight.',
      leading: Image.asset('assets/Logo.png', width: 28, height: 28),
      trailing: UserInitialsLogoButton(
        displayName: displayName,
        onPressed: onMenuPressed,
      ),
    );
  }
}

class _HomeTabAndContentSection extends StatelessWidget {
  const _HomeTabAndContentSection({
    required this.selectedTabIndex,
    required this.selectedDate,
    required this.firestoreService,
    required this.onTabSelected,
    required this.onDateSelected,
  });

  final int selectedTabIndex;
  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabNavigationWidget(
            selectedIndex: selectedTabIndex,
            onTabSelected: onTabSelected,
          ),
        ),
        _HomeTabContent(
          selectedTabIndex: selectedTabIndex,
          selectedDate: selectedDate,
          firestoreService: firestoreService,
          onDateSelected: onDateSelected,
        ),
      ],
    );
  }
}

class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent({
    required this.selectedTabIndex,
    required this.selectedDate,
    required this.firestoreService,
    required this.onDateSelected,
  });

  final int selectedTabIndex;
  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    // Check if jobs are configured
    return StreamBuilder<List<JobTimeSlot>>(
      stream: firestoreService.getJobTimeSlots(),
      builder: (context, jobSnapshot) {
        final hasJobs = jobSnapshot.hasData && jobSnapshot.data!.isNotEmpty;

        // Show setup card if no jobs configured
        if (!hasJobs) {
          return NoJobsSetupCard(
            onSetupPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobsManagementScreen(),
                ),
              );
            },
          );
        }

        // Show regular content if jobs are configured
        if (selectedTabIndex == 0) {
          return _HomeScheduleTabView(
            selectedDate: selectedDate,
            firestoreService: firestoreService,
            onDateSelected: onDateSelected,
          );
        }

        return _HomeDetailsTabView(
          selectedDate: selectedDate,
          firestoreService: firestoreService,
        );
      },
    );
  }
}

class _HomeScheduleTabView extends StatelessWidget {
  const _HomeScheduleTabView({
    required this.selectedDate,
    required this.firestoreService,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SectionCard(
        child: StreamBuilder<List<ScheduleItem>>(
          stream: firestoreService.getScheduleItems(),
          builder: (context, scheduleSnapshot) {
            final daysWithSchedule = <int>{};
            final schedulesByDay = <int, List<String>>{};
            final scheduleItemsByDay = <int, List<ScheduleItem>>{};
            if (scheduleSnapshot.hasData) {
              for (final item in scheduleSnapshot.data!) {
                daysWithSchedule.add(item.day);
                schedulesByDay.putIfAbsent(item.day, () => []).add(item.title);
                scheduleItemsByDay.putIfAbsent(item.day, () => []).add(item);
              }
            }

            return StreamBuilder<List<JobTimeSlot>>(
              stream: firestoreService.getJobTimeSlots(),
              builder: (context, slotSnapshot) {
                final allJobSlots = slotSnapshot.data ?? const [];
                final timeRangesByJobName =
                    _buildTimeRangesByJobName(allJobSlots);

                // Filter schedules to only show those for active jobs
                final activeJobNames =
                    JobTimeHelper.getActiveJobNames(allJobSlots);
                final filteredSchedules = (scheduleSnapshot.data ?? const [])
                    .where((schedule) =>
                        activeJobNames.contains(schedule.jobName.trim()))
                    .toList();

                // Rebuild the schedule maps with only active job schedules
                final activeDaysWithSchedule = <int>{};
                final activeSchedulesByDay = <int, List<String>>{};
                final activeScheduleItemsByDay = <int, List<ScheduleItem>>{};
                for (final item in filteredSchedules) {
                  activeDaysWithSchedule.add(item.day);
                  activeSchedulesByDay
                      .putIfAbsent(item.day, () => [])
                      .add(item.title);
                  activeScheduleItemsByDay
                      .putIfAbsent(item.day, () => [])
                      .add(item);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarWidget(
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        onDateSelected(date);
                        _showScheduleDetailsDialog(
                          context: context,
                          selectedDate: date,
                          schedulesForDay: activeScheduleItemsByDay[date.day] ??
                              const <ScheduleItem>[],
                          timeRangesByJobName: timeRangesByJobName,
                        );
                      },
                      daysWithSchedule: activeDaysWithSchedule.toList(),
                      daysWithNotes: const [],
                      schedulesByDay: activeSchedulesByDay,
                      notesByDay: const {},
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showScheduleDetailsDialog({
    required BuildContext context,
    required DateTime selectedDate,
    required List<ScheduleItem> schedulesForDay,
    required Map<String, String> timeRangesByJobName,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ScheduleDetailsModal(
          selectedDate: selectedDate,
          schedules: schedulesForDay,
          timeRangesByJobName: timeRangesByJobName,
          onCreateSchedulePressed: () {
            Navigator.of(dialogContext).pop();
            _showCreateScheduleDialog(
                context: context, initialDate: selectedDate);
          },
        ),
      ),
    );
  }

  void _showCreateScheduleDialog({
    required BuildContext context,
    required DateTime initialDate,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CreateScheduleModal(initialDate: initialDate),
        ),
      ),
    );
  }

  Map<String, String> _buildTimeRangesByJobName(List<JobTimeSlot> slots) {
    final groupedRanges = <String, List<String>>{};

    for (final slot in slots) {
      final jobName = slot.jobName.trim();
      if (jobName.isEmpty ||
          slot.startTime.trim().isEmpty ||
          slot.endTime.trim().isEmpty) {
        continue;
      }

      final timeOfDayLabel = slot.timeOfDay.trim().isEmpty
          ? 'Slot'
          : '${slot.timeOfDay[0].toUpperCase()}${slot.timeOfDay.substring(1)}';
      final range = '$timeOfDayLabel: ${slot.startTime} - ${slot.endTime}';
      groupedRanges.putIfAbsent(jobName, () => []).add(range);
    }

    return groupedRanges.map(
      (jobName, ranges) => MapEntry(jobName, ranges.toSet().join(' • ')),
    );
  }
}

class _HomeAddScheduleFab extends StatelessWidget {
  const _HomeAddScheduleFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.accent,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class _HomeMenuSheet extends StatelessWidget {
  const _HomeMenuSheet({
    required this.onManageJobsPressed,
    required this.onLogoutPressed,
  });

  final VoidCallback onManageJobsPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.work_outline, color: Colors.white),
          title: const Text('Manage Your Jobs',
              style: TextStyle(color: Colors.white)),
          onTap: onManageJobsPressed,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: onLogoutPressed,
        ),
      ],
    );
  }
}

class _HomeDetailsTabView extends StatelessWidget {
  const _HomeDetailsTabView({
    required this.selectedDate,
    required this.firestoreService,
  });

  final DateTime selectedDate;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SectionCard(
        child: StreamBuilder<List<ScheduleItem>>(
          stream: firestoreService.getScheduleItems(),
          builder: (context, scheduleSnapshot) {
            final scheduleItems = scheduleSnapshot.data ?? const [];

            return StreamBuilder<List<JobTimeSlot>>(
              stream: firestoreService.getJobTimeSlots(),
              builder: (context, slotSnapshot) {
                final allJobSlots = slotSnapshot.data ?? const [];

                // Filter schedules to only show those for active jobs
                final activeJobNames =
                    JobTimeHelper.getActiveJobNames(allJobSlots);
                final filteredSchedules = scheduleItems
                    .where((schedule) =>
                        activeJobNames.contains(schedule.jobName.trim()))
                    .toList();

                // Filter to selected date
                final schedulesForDate = filteredSchedules
                    .where((schedule) => schedule.day == selectedDate.day)
                    .toList();

                if (schedulesForDate.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            color: Colors.grey.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No active tasks for this day',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedulesForDate.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final schedule = schedulesForDate[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF3D1E6F).withValues(alpha: 0.7),
                        border: Border.all(
                          color: const Color(0xFF7C5FDD).withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      schedule.jobName,
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (schedule.place.isNotEmpty)
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                            ],
                          ),
                          if (schedule.place.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              schedule.place,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (schedule.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              schedule.notes,
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
