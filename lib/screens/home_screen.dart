import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/tab_navigation_widget.dart';
import '../widgets/schedule_item_widget.dart';
import '../widgets/note_view_widget.dart';
import '../widgets/create_schedule_modal.dart';
import '../services/firestore_service.dart';

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB5A957),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.nights_stay,
                                  color: Colors.white, size: 16),
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
                  // Calendar View
                  if (_selectedTabIndex == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C0A4A).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF7C5FDD).withValues(alpha: 0.3),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: CalendarWidget(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedDate = date),
                        ),
                      ),
                    ),
                  // Note View
                  if (_selectedTabIndex == 1)
                    NoteViewWidget(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      onAddNotePressed: () {},
                    ),
                  // Schedule Items Section
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
                              'Schedule',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C5FDD)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                  color: Color(0xFF7C5FDD),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<ScheduleItem>>(
                          stream: _firestoreService.getScheduleItems(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF7C5FDD)),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 10),
                                child: Center(
                                  child: Text(
                                    'Error loading schedule: ${snapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            final scheduleItems = snapshot.data ?? [];

                            if (scheduleItems.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        color: Colors.grey[600],
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No schedule items yet',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap the + button to create one',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: scheduleItems.take(3).map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ScheduleItemWidget(
                                    day: item.day,
                                    title: item.title,
                                    time: item.time,
                                    place: item.place,
                                    notes: item.notes,
                                    isCompleted: item.isCompleted,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const CreateScheduleModal(),
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
