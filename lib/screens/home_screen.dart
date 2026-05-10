import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/tab_navigation_widget.dart';
import '../widgets/note_view_widget.dart';
import '../widgets/create_schedule_modal.dart';
import '../services/firestore_service.dart';
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/Logo.png',
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'moonlight.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white, size: 22),
                        onPressed: () => _showMenu(context),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Tab Navigation
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabNavigationWidget(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) =>
                        setState(() => _selectedTabIndex = index),
                  ),
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C0A4A)
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF7C5FDD)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: StreamBuilder<List<ScheduleItem>>(
                              stream: _firestoreService.getScheduleItems(),
                              builder: (context, snapshot) {
                                final daysWithSchedule = <int>{};
                                final schedulesByDay = <int, List<String>>{};
                                if (snapshot.hasData) {
                                  for (var item in snapshot.data!) {
                                    daysWithSchedule.add(item.day);
                                    schedulesByDay
                                        .putIfAbsent(item.day, () => [])
                                        .add(item.title);
                                  }
                                }

                                return CalendarWidget(
                                  selectedDate: _selectedDate,
                                  onDateSelected: (date) =>
                                      setState(() => _selectedDate = date),
                                  daysWithSchedule: daysWithSchedule.toList(),
                                  schedulesByDay: schedulesByDay,
                                );
                              },
                            ),
                          ),
                        )
                      : NoteViewWidget(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedDate = date),
                          onAddNotePressed: () {},
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const CreateScheduleModal(),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF7C5FDD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D1265),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
