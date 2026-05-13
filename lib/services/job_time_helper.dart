import '../services/firestore_service.dart';

class JobTimeHelper {
  /// Converts time string in format "HH:MM" to minutes since midnight
  static int timeStringToMinutes(String timeString) {
    try {
      final parts = timeString.trim().split(':');
      if (parts.length != 2) return 0;
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return hours * 60 + minutes;
    } catch (e) {
      return 0;
    }
  }

  /// Checks if a job is currently active based on current time
  static bool isJobActive(JobTimeSlot job) {
    final now = DateTime.now();
    final currentTimeInMinutes = now.hour * 60 + now.minute;

    final startTimeInMinutes = timeStringToMinutes(job.startTime);
    final endTimeInMinutes = timeStringToMinutes(job.endTime);

    // Handle case where job spans midnight (e.g., 10pm to 2am)
    if (endTimeInMinutes <= startTimeInMinutes) {
      return currentTimeInMinutes >= startTimeInMinutes ||
          currentTimeInMinutes < endTimeInMinutes;
    }

    // Normal case: job within same day
    return currentTimeInMinutes >= startTimeInMinutes &&
        currentTimeInMinutes < endTimeInMinutes;
  }

  /// Filters jobs to only include active ones
  static List<JobTimeSlot> getActiveJobs(List<JobTimeSlot> allJobs) {
    return allJobs.where((job) => isJobActive(job)).toList();
  }

  /// Gets all job names that are currently active
  static Set<String> getActiveJobNames(List<JobTimeSlot> allJobs) {
    return getActiveJobs(allJobs).map((job) => job.jobName.trim()).toSet();
  }

  /// Filters schedule items to only include those for active jobs
  static List<ScheduleItem> filterSchedulesByActiveJobs(
    List<ScheduleItem> schedules,
    List<JobTimeSlot> jobTimeSlots,
  ) {
    final activeJobNames = getActiveJobNames(jobTimeSlots);
    return schedules
        .where((schedule) => activeJobNames.contains(schedule.jobName.trim()))
        .toList();
  }
}
