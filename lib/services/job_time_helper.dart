import '../services/firestore_service.dart';

class JobTimeHelper {
  /// Converts a time string to minutes since midnight
  static int? timeStringToMinutes(String timeString) {
    final normalized = timeString
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\u00A0\u202F]+'), '');
    if (normalized.isEmpty) {
      return null;
    }

    final twelveHourMatch =
        RegExp(r'^(\d{1,2}):(\d{2})(AM|PM)$').firstMatch(normalized);
    if (twelveHourMatch != null) {
      final hour = int.parse(twelveHourMatch.group(1)!);
      final minute = int.parse(twelveHourMatch.group(2)!);
      final meridiem = twelveHourMatch.group(3)!;

      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        return null;
      }

      var normalizedHour = hour % 12;
      if (meridiem == 'PM') {
        normalizedHour += 12;
      }
      return normalizedHour * 60 + minute;
    }

    final twentyFourHourMatch =
        RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
    if (twentyFourHourMatch != null) {
      final hour = int.parse(twentyFourHourMatch.group(1)!);
      final minute = int.parse(twentyFourHourMatch.group(2)!);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }
      return hour * 60 + minute;
    }

    return null;
  }

  /// Checks if a job is currently active based on current time
  static bool isJobActive(JobTimeSlot job, {DateTime? now}) {
    final resolvedNow = now ?? DateTime.now();
    final currentTimeInMinutes = resolvedNow.hour * 60 + resolvedNow.minute;

    final startTimeInMinutes = timeStringToMinutes(job.startTime);
    final endTimeInMinutes = timeStringToMinutes(job.endTime);
    if (startTimeInMinutes == null || endTimeInMinutes == null) {
      return false;
    }

    // Same start/end does not represent a valid active window.
    if (startTimeInMinutes == endTimeInMinutes) {
      return false;
    }

    // Handle case where job spans midnight (e.g., 10pm to 2am)
    if (endTimeInMinutes < startTimeInMinutes) {
      return currentTimeInMinutes >= startTimeInMinutes ||
          currentTimeInMinutes < endTimeInMinutes;
    }

    // Normal case: job within same day
    return currentTimeInMinutes >= startTimeInMinutes &&
        currentTimeInMinutes < endTimeInMinutes;
  }

  /// Filters jobs to only include active ones
  static List<JobTimeSlot> getActiveJobs(
    List<JobTimeSlot> allJobs, {
    DateTime? now,
  }) {
    return allJobs.where((job) => isJobActive(job, now: now)).toList();
  }

  /// Gets all job names that are currently active
  static Set<String> getActiveJobNames(
    List<JobTimeSlot> allJobs, {
    DateTime? now,
  }) {
    return getActiveJobs(allJobs, now: now)
        .map((job) => job.jobName.trim())
        .toSet();
  }

  /// Filters schedule items to only include those for active jobs
  static List<ScheduleItem> filterSchedulesByActiveJobs(
    List<ScheduleItem> schedules,
    List<JobTimeSlot> jobTimeSlots, {
    DateTime? now,
  }) {
    final activeJobNames = getActiveJobNames(jobTimeSlots, now: now);
    return schedules
        .where((schedule) => activeJobNames.contains(schedule.jobName.trim()))
        .toList();
  }
}
