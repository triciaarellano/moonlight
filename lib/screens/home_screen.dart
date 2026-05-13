import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/firestore_service.dart';
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
import 'edit_profile_screen.dart';
import 'jobs_screen.dart';

enum _ScheduleShiftFilter {
  morning,
  night,
}

class _HomeAmbience {
  const _HomeAmbience({
    required this.isMorning,
    required this.scaffoldBackground,
    required this.screenGradient,
    required this.systemOverlayStyle,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.inactiveText,
    required this.surfaceStrong,
    required this.cardSurface,
    required this.cardBorder,
    required this.accent,
    required this.accentAlt,
    required this.accentSoft,
    required this.accentText,
    required this.onAccent,
    required this.shadow,
    required this.fab,
    required this.fabForeground,
    required this.avatarGradient,
    required this.logoBackground,
    required this.orbPrimary,
    required this.orbSecondary,
    required this.scheduleDot,
    required this.noteDot,
    required this.weekendText,
  });

  final bool isMorning;
  final Color scaffoldBackground;
  final LinearGradient screenGradient;
  final SystemUiOverlayStyle systemOverlayStyle;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color inactiveText;
  final Color surfaceStrong;
  final Color cardSurface;
  final Color cardBorder;
  final Color accent;
  final Color accentAlt;
  final Color accentSoft;
  final Color accentText;
  final Color onAccent;
  final Color shadow;
  final Color fab;
  final Color fabForeground;
  final LinearGradient avatarGradient;
  final Color logoBackground;
  final Color orbPrimary;
  final Color orbSecondary;
  final Color scheduleDot;
  final Color noteDot;
  final Color weekendText;

  static _HomeAmbience forShift(_ScheduleShiftFilter shift) {
    if (shift == _ScheduleShiftFilter.morning) {
      return _HomeAmbience(
        isMorning: true,
        scaffoldBackground: const Color(0xFFFFF1D5),
        screenGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDFA3),
            Color(0xFFFFF8EA),
            Color(0xFFFFC48A),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFFFFF1D5),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        primaryText: const Color(0xFF352112),
        secondaryText: const Color(0xFF725039),
        mutedText: const Color(0xFF9B7358),
        inactiveText: const Color(0xFFB58A68),
        surfaceStrong: const Color(0xFFFFE5BF).withValues(alpha: 0.82),
        cardSurface: const Color(0xFFFFFAEF).withValues(alpha: 0.88),
        cardBorder: const Color(0xFFE99543).withValues(alpha: 0.34),
        accent: const Color(0xFFE9742A),
        accentAlt: const Color(0xFFFFB545),
        accentSoft: const Color(0xFFFFD18B).withValues(alpha: 0.5),
        accentText: const Color(0xFF9B4214),
        onAccent: Colors.white,
        shadow: const Color(0xFF9D551C).withValues(alpha: 0.18),
        fab: const Color(0xFFE9742A),
        fabForeground: Colors.white,
        avatarGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB545), Color(0xFFE9742A)],
        ),
        logoBackground: Colors.white.withValues(alpha: 0.62),
        orbPrimary: const Color(0xFFFFB545).withValues(alpha: 0.48),
        orbSecondary: const Color(0xFFFF6F61).withValues(alpha: 0.16),
        scheduleDot: const Color(0xFFE9742A),
        noteDot: const Color(0xFF2F9C95),
        weekendText: const Color(0xFFB24A2D),
      );
    }

    return _HomeAmbience(
      isMorning: false,
      scaffoldBackground: AppColors.background,
      screenGradient: AppGradients.screenBackground,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      primaryText: Colors.white,
      secondaryText: const Color(0xFFD7D0E9),
      mutedText: const Color(0xFFA59BB8),
      inactiveText: const Color(0xFF746B86),
      surfaceStrong: AppColors.cardSurface.withValues(alpha: 0.72),
      cardSurface: AppColors.surface.withValues(alpha: 0.62),
      cardBorder: AppColors.accent.withValues(alpha: 0.3),
      accent: AppColors.accent,
      accentAlt: const Color(0xFFB5A957),
      accentSoft: AppColors.accent.withValues(alpha: 0.22),
      accentText: const Color(0xFFE5DFFF),
      onAccent: Colors.white,
      shadow: AppColors.background.withValues(alpha: 0.32),
      fab: AppColors.accent,
      fabForeground: Colors.white,
      avatarGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C5FDD), Color(0xFF4B2FA4)],
      ),
      logoBackground: Colors.white.withValues(alpha: 0.08),
      orbPrimary: AppColors.accent.withValues(alpha: 0.24),
      orbSecondary: AppColors.label.withValues(alpha: 0.12),
      scheduleDot: AppColors.label,
      noteDot: AppColors.accent,
      weekendText: const Color(0xFFFF8D8D),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  late DateTime _selectedDate;
  late FirestoreService _firestoreService;
  _ScheduleShiftFilter? _selectedShiftFilter = _ScheduleShiftFilter.morning;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firestoreService = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    final selectedShift = _selectedShiftFilter ?? _ScheduleShiftFilter.morning;
    final ambience = _HomeAmbience.forShift(selectedShift);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ambience.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: ambience.scaffoldBackground,
        body: AppGradientScreenShell(
          gradient: ambience.screenGradient,
          child: Stack(
            children: [
              Positioned.fill(child: _HomeAmbientBackdrop(ambience: ambience)),
              SingleChildScrollView(
                child: Column(
                  children: [
                    _HomeTopHeaderSection(
                      displayName:
                          FirebaseAuth.instance.currentUser?.displayName,
                      ambience: ambience,
                      onMenuPressed: () => _showMenu(context),
                    ),
                    _HomeShiftHero(
                      selectedShift: selectedShift,
                      ambience: ambience,
                    ),
                    _HomeTabAndContentSection(
                      selectedTabIndex: _selectedTabIndex,
                      selectedDate: _selectedDate,
                      firestoreService: _firestoreService,
                      selectedShiftFilter: selectedShift,
                      ambience: ambience,
                      onTabSelected: (index) =>
                          setState(() => _selectedTabIndex = index),
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      onShiftFilterChanged: (shift) =>
                          setState(() => _selectedShiftFilter = shift),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _HomeAddScheduleFab(
          ambience: ambience,
          onPressed: () => _showCreateScheduleDialog(context),
        ),
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
    final ambience = _HomeAmbience.forShift(
        _selectedShiftFilter ?? _ScheduleShiftFilter.morning);

    showModalBottomSheet(
      context: context,
      backgroundColor: ambience.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _HomeMenuSheet(
        ambience: ambience,
        onEditProfilePressed: () async {
          Navigator.pop(sheetContext);
          final didUpdate = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ),
          );
          if (didUpdate == true && mounted) {
            setState(() {});
          }
        },
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

class _HomeAmbientBackdrop extends StatelessWidget {
  const _HomeAmbientBackdrop({required this.ambience});

  final _HomeAmbience ambience;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: ambience.isMorning ? -68 : -86,
            right: ambience.isMorning ? -42 : -70,
            child: _AmbientOrb(
              size: ambience.isMorning ? 190 : 230,
              color: ambience.orbPrimary,
              blurRadius: ambience.isMorning ? 42 : 58,
            ),
          ),
          Positioned(
            top: 160,
            left: -72,
            child: _AmbientOrb(
              size: 170,
              color: ambience.orbSecondary,
              blurRadius: 48,
            ),
          ),
          Positioned(
            right: -96,
            bottom: 40,
            child: _AmbientOrb(
              size: 220,
              color: ambience.accentSoft,
              blurRadius: 70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.blurRadius,
  });

  final double size;
  final Color color;
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: blurRadius / 4,
          ),
        ],
      ),
    );
  }
}

class _HomeShiftHero extends StatelessWidget {
  const _HomeShiftHero({
    required this.selectedShift,
    required this.ambience,
  });

  final _ScheduleShiftFilter selectedShift;
  final _HomeAmbience ambience;

  @override
  Widget build(BuildContext context) {
    final isMorning = selectedShift == _ScheduleShiftFilter.morning;
    final icon = isMorning ? Icons.wb_sunny_outlined : Icons.nights_stay;
    final title = isMorning ? 'Morning Mode' : 'Night Mode';
    final subtitle = isMorning
        ? 'A brighter AM view for day schedules.'
        : 'Focused low-light view for evening schedules.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ambience.cardSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ambience.cardBorder),
          boxShadow: [
            BoxShadow(
              color: ambience.shadow,
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [ambience.accentAlt, ambience.accent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ambience.accent.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: ambience.onAccent, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: ambience.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: ambience.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ambience.accentSoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: ambience.accent.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                isMorning ? 'AM' : 'PM',
                style: TextStyle(
                  color: ambience.accentText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTopHeaderSection extends StatelessWidget {
  const _HomeTopHeaderSection({
    required this.displayName,
    required this.ambience,
    required this.onMenuPressed,
  });

  final String? displayName;
  final _HomeAmbience ambience;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return CommonTopHeaderRow(
      title: 'moonlight.',
      titleStyle: TextStyle(
        color: ambience.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.1,
      ),
      leading: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: ambience.logoBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ambience.cardBorder),
        ),
        child: Image.asset('assets/Logo.png'),
      ),
      trailing: UserInitialsLogoButton(
        displayName: displayName,
        gradient: ambience.avatarGradient,
        borderColor: ambience.cardBorder,
        textColor: ambience.onAccent,
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
    required this.selectedShiftFilter,
    required this.ambience,
    required this.onTabSelected,
    required this.onDateSelected,
    required this.onShiftFilterChanged,
  });

  final int selectedTabIndex;
  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final _ScheduleShiftFilter selectedShiftFilter;
  final _HomeAmbience ambience;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<_ScheduleShiftFilter> onShiftFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabNavigationWidget(
            selectedIndex: selectedTabIndex,
            backgroundColor: ambience.surfaceStrong,
            selectedBackgroundColor: ambience.accent,
            selectedTextColor: ambience.onAccent,
            unselectedTextColor: ambience.secondaryText,
            borderColor: ambience.cardBorder,
            onTabSelected: onTabSelected,
          ),
        ),
        _HomeTabContent(
          selectedTabIndex: selectedTabIndex,
          selectedDate: selectedDate,
          firestoreService: firestoreService,
          selectedShiftFilter: selectedShiftFilter,
          ambience: ambience,
          onDateSelected: onDateSelected,
          onShiftFilterChanged: onShiftFilterChanged,
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
    required this.selectedShiftFilter,
    required this.ambience,
    required this.onDateSelected,
    required this.onShiftFilterChanged,
  });

  final int selectedTabIndex;
  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final _ScheduleShiftFilter selectedShiftFilter;
  final _HomeAmbience ambience;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<_ScheduleShiftFilter> onShiftFilterChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobTimeSlot>>(
      stream: firestoreService.getJobTimeSlots(),
      builder: (context, jobSnapshot) {
        final allJobSlots = jobSnapshot.data ?? const <JobTimeSlot>[];
        final hasJobs = jobSnapshot.hasData && allJobSlots.isNotEmpty;

        if (!hasJobs) {
          return NoJobsSetupCard(
            accentColor: ambience.accent,
            accentEndColor: ambience.accentAlt,
            primaryTextColor: ambience.primaryText,
            secondaryTextColor: ambience.secondaryText,
            mutedTextColor: ambience.mutedText,
            buttonTextColor: ambience.onAccent,
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

        final selectedJobNamesFilter =
            _jobNamesForShift(allJobSlots, selectedShiftFilter);

        return Column(
          children: [
            _HomeScheduleShiftToggle(
              selectedShift: selectedShiftFilter,
              ambience: ambience,
              onShiftChanged: onShiftFilterChanged,
            ),
            if (selectedTabIndex == 0)
              _HomeScheduleTabView(
                selectedDate: selectedDate,
                firestoreService: firestoreService,
                allJobSlots: allJobSlots,
                selectedJobNamesFilter: selectedJobNamesFilter,
                ambience: ambience,
                onDateSelected: onDateSelected,
              )
            else
              _HomeDetailsTabView(
                selectedDate: selectedDate,
                firestoreService: firestoreService,
                selectedShiftFilter: selectedShiftFilter,
                selectedJobNamesFilter: selectedJobNamesFilter,
                ambience: ambience,
              ),
          ],
        );
      },
    );
  }
}

class _HomeScheduleTabView extends StatelessWidget {
  const _HomeScheduleTabView({
    required this.selectedDate,
    required this.firestoreService,
    required this.allJobSlots,
    required this.selectedJobNamesFilter,
    required this.ambience,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final List<JobTimeSlot> allJobSlots;
  final Set<String> selectedJobNamesFilter;
  final _HomeAmbience ambience;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SectionCard(
        backgroundColor: ambience.cardSurface,
        borderColor: ambience.cardBorder,
        child: StreamBuilder<List<ScheduleItem>>(
          stream: firestoreService.getScheduleItems(),
          builder: (context, scheduleSnapshot) {
            final filteredSchedules = _filterSchedulesByJobNames(
              scheduleSnapshot.data ?? const <ScheduleItem>[],
              selectedJobNamesFilter,
            );
            final scheduleDays = <int>{};
            final schedulesByDay = <int, List<String>>{};
            final scheduleItemsByDay = <int, List<ScheduleItem>>{};
            for (final item in filteredSchedules) {
              scheduleDays.add(item.day);
              schedulesByDay.putIfAbsent(item.day, () => []).add(item.title);
              scheduleItemsByDay.putIfAbsent(item.day, () => []).add(item);
            }

            final timeRangesByJobName = _buildTimeRangesByJobName(allJobSlots);

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarWidget(
                  selectedDate: selectedDate,
                  monthTextColor: ambience.primaryText,
                  navigationIconColor: ambience.primaryText,
                  weekdayTextColor: ambience.secondaryText,
                  weekendTextColor: ambience.weekendText,
                  dayTextColor: ambience.primaryText,
                  mutedDayTextColor: ambience.inactiveText,
                  selectedDayColor: ambience.accent,
                  selectedDayTextColor: ambience.onAccent,
                  todayFillColor: ambience.accentSoft,
                  todayBorderColor: ambience.accent.withValues(alpha: 0.48),
                  scheduleDotColor: ambience.scheduleDot,
                  noteDotColor: ambience.noteDot,
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
                  daysWithSchedule: scheduleDays.toList(),
                  daysWithNotes: const [],
                  schedulesByDay: schedulesByDay,
                  notesByDay: const {},
                ),
              ],
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
  const _HomeAddScheduleFab({
    required this.ambience,
    required this.onPressed,
  });

  final _HomeAmbience ambience;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: ambience.fab,
      foregroundColor: ambience.fabForeground,
      elevation: ambience.isMorning ? 8 : 6,
      child: const Icon(Icons.add),
    );
  }
}

class _HomeMenuSheet extends StatelessWidget {
  const _HomeMenuSheet({
    required this.ambience,
    required this.onEditProfilePressed,
    required this.onManageJobsPressed,
    required this.onLogoutPressed,
  });

  final _HomeAmbience ambience;
  final VoidCallback onEditProfilePressed;
  final VoidCallback onManageJobsPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.person_outline, color: ambience.primaryText),
          title: Text(
            'Edit Profile',
            style: TextStyle(color: ambience.primaryText),
          ),
          onTap: onEditProfilePressed,
        ),
        ListTile(
          leading: Icon(Icons.work_outline, color: ambience.primaryText),
          title: Text(
            'Manage Your Jobs',
            style: TextStyle(color: ambience.primaryText),
          ),
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
    required this.selectedShiftFilter,
    required this.selectedJobNamesFilter,
    required this.ambience,
  });

  final DateTime selectedDate;
  final FirestoreService firestoreService;
  final _ScheduleShiftFilter selectedShiftFilter;
  final Set<String> selectedJobNamesFilter;
  final _HomeAmbience ambience;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SectionCard(
        backgroundColor: ambience.cardSurface,
        borderColor: ambience.cardBorder,
        child: StreamBuilder<List<ScheduleItem>>(
          stream: firestoreService.getScheduleItems(),
          builder: (context, scheduleSnapshot) {
            final scheduleItems =
                scheduleSnapshot.data ?? const <ScheduleItem>[];
            final filteredSchedules = _filterSchedulesByJobNames(
                scheduleItems, selectedJobNamesFilter);
            final schedulesForDate = filteredSchedules
                .where((schedule) => schedule.day == selectedDate.day)
                .toList();

            if (schedulesForDate.isEmpty) {
              final shiftLabel =
                  selectedShiftFilter == _ScheduleShiftFilter.morning
                      ? 'morning'
                      : 'night';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        color: ambience.inactiveText,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No $shiftLabel schedules for this day',
                        style: TextStyle(
                          color: ambience.mutedText,
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
                    borderRadius: BorderRadius.circular(14),
                    color: ambience.surfaceStrong,
                    border: Border.all(
                      color: ambience.cardBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ambience.shadow,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
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
                                  style: TextStyle(
                                    color: ambience.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  schedule.jobName,
                                  style: TextStyle(
                                    color: ambience.secondaryText,
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
                              color: ambience.mutedText,
                            ),
                        ],
                      ),
                      if (schedule.place.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          schedule.place,
                          style: TextStyle(
                            color: ambience.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (schedule.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          schedule.notes,
                          style: TextStyle(
                            color: ambience.primaryText.withValues(alpha: 0.78),
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
        ),
      ),
    );
  }
}

class _HomeScheduleShiftToggle extends StatelessWidget {
  const _HomeScheduleShiftToggle({
    required this.selectedShift,
    required this.ambience,
    required this.onShiftChanged,
  });

  final _ScheduleShiftFilter selectedShift;
  final _HomeAmbience ambience;
  final ValueChanged<_ScheduleShiftFilter> onShiftChanged;

  @override
  Widget build(BuildContext context) {
    final isNight = selectedShift == _ScheduleShiftFilter.night;
    final activeColor = ambience.accent;
    final helperLabel =
        isNight ? 'Showing PM/evening schedules' : 'Showing AM/day schedules';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        borderColor: activeColor.withValues(alpha: 0.45),
        backgroundColor: ambience.cardSurface,
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isNight ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
                key: ValueKey(selectedShift),
                color: activeColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shift Filter',
                    style: TextStyle(
                      color: ambience.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: activeColor.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text(
                      helperLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isNight ? ambience.mutedText : activeColor,
                    fontSize: 12,
                    fontWeight: isNight ? FontWeight.w500 : FontWeight.w700,
                  ),
                  child: const Text('Morning'),
                ),
                Switch.adaptive(
                  value: isNight,
                  onChanged: (value) => onShiftChanged(
                    value
                        ? _ScheduleShiftFilter.night
                        : _ScheduleShiftFilter.morning,
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: ambience.accent,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: ambience.accent.withValues(alpha: 0.45),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isNight ? activeColor : ambience.mutedText,
                    fontSize: 12,
                    fontWeight: isNight ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: const Text('Night'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Set<String> _jobNamesForShift(
  List<JobTimeSlot> slots,
  _ScheduleShiftFilter shift,
) {
  final selectedJobNames = <String>{};

  for (final slot in slots) {
    final normalizedJobName = _normalizeJobName(slot.jobName);
    if (normalizedJobName.isEmpty) {
      continue;
    }

    final normalizedTimeOfDay = slot.timeOfDay.trim().toLowerCase();
    final isMorning = normalizedTimeOfDay == 'morning' ||
        normalizedTimeOfDay == 'am' ||
        normalizedTimeOfDay == 'day';
    final isNight = normalizedTimeOfDay == 'night' ||
        normalizedTimeOfDay == 'evening' ||
        normalizedTimeOfDay == 'pm';

    final shouldInclude = shift == _ScheduleShiftFilter.morning
        ? isMorning
        : (isNight || (!isMorning && normalizedTimeOfDay.isNotEmpty));

    if (shouldInclude) {
      selectedJobNames.add(normalizedJobName);
    }
  }

  return selectedJobNames;
}

List<ScheduleItem> _filterSchedulesByJobNames(
  List<ScheduleItem> schedules,
  Set<String> selectedJobNames,
) {
  if (selectedJobNames.isEmpty) {
    return const <ScheduleItem>[];
  }

  return schedules
      .where((schedule) =>
          selectedJobNames.contains(_normalizeJobName(schedule.jobName)))
      .toList();
}

String _normalizeJobName(String? value) => value?.trim().toLowerCase() ?? '';
