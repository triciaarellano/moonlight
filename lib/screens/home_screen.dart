import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../theme/app_style_tokens.dart';
import '../widgets/app_gradient_screen_shell.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/common_top_header_row.dart';
import '../widgets/create_schedule_modal.dart';
import '../widgets/note_view_widget.dart';
import '../widgets/schedule_details_modal.dart';
import '../widgets/section_card.dart';
import '../widgets/tab_navigation_widget.dart';
import '../widgets/user_initials_logo_button.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  late DateTime _selectedDate;
  late FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientScreenShell(
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
        onSettingsPressed: () {
          Navigator.pop(sheetContext);
          Navigator.push(
            sheetContext,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabNavigationWidget(
              selectedIndex: selectedTabIndex,
              onTabSelected: onTabSelected,
            ),
          ),
          Expanded(
            child: _HomeTabContent(
              selectedTabIndex: selectedTabIndex,
              selectedDate: selectedDate,
              firestoreService: firestoreService,
              onDateSelected: onDateSelected,
            ),
          ),
        ],
      ),
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
    if (selectedTabIndex == 0) {
      return _HomeScheduleTabView(
        selectedDate: selectedDate,
        firestoreService: firestoreService,
        onDateSelected: onDateSelected,
      );
    }

    return NoteViewWidget(
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
      onAddNotePressed: () {},
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
                final timeRangesByJobName =
                    _buildTimeRangesByJobName(slotSnapshot.data ?? const []);

                return CalendarWidget(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    onDateSelected(date);
                    _showScheduleDetailsDialog(
                      context: context,
                      selectedDate: date,
                      schedulesForDay: scheduleItemsByDay[date.day] ??
                          const <ScheduleItem>[],
                      timeRangesByJobName: timeRangesByJobName,
                    );
                  },
                  daysWithSchedule: daysWithSchedule.toList(),
                  schedulesByDay: schedulesByDay,
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
    required this.onSettingsPressed,
    required this.onLogoutPressed,
  });

  final VoidCallback onSettingsPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.white),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          onTap: onSettingsPressed,
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
