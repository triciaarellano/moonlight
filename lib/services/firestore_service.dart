import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ScheduleItem {
  final String id;
  final int day;
  final String title;
  final String time;
  final String place;
  final String notes;
  final bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.day,
    required this.title,
    required this.time,
    required this.place,
    required this.notes,
    required this.isCompleted,
  });

  factory ScheduleItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduleItem(
      id: doc.id,
      day: data['day'] ?? 0,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      place: data['place'] ?? '',
      notes: data['notes'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'time': time,
      'place': place,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? noteDate;
  final String? noteTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.noteDate,
    this.noteTime,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      noteDate: (data['noteDate'] as Timestamp?)?.toDate(),
      noteTime: data['noteTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'noteDate': noteDate,
      'noteTime': noteTime,
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Schedule methods
  Stream<List<ScheduleItem>> getScheduleItems() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('schedule')
          .orderBy('day')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ScheduleItem.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (kDebugMode) {
          print('Error fetching schedule items: $error');
        }
        return <ScheduleItem>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in getScheduleItems: $e');
      }
      return Stream.value([]);
    }
  }

  Future<void> addScheduleItem(ScheduleItem item) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedule')
        .add(item.toMap());
  }

  Future<void> updateScheduleItem(ScheduleItem item) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedule')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteScheduleItem(String itemId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('schedule')
        .doc(itemId)
        .delete();
  }

  // Notes methods
  Stream<List<Note>> getNotes() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList())
          .handleError((error) {
        if (kDebugMode) {
          print('Error fetching notes: $error');
        }
        return <Note>[];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in getNotes: $e');
      }
      return Stream.value([]);
    }
  }

  Future<void> addNote(Note note) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .add(note.toMap());
  }

  Future<void> updateNote(Note note) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(note.id)
        .update({
      'title': note.title,
      'content': note.content,
      'updatedAt': note.updatedAt,
    });
  }

  Future<void> deleteNote(String noteId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
