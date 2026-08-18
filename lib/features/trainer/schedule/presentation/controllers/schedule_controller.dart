import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/schedule_summary_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/usecases/cancel_session_usecase.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/usecases/get_schedule_summary_usecase.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/usecases/get_session_details_usecase.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/usecases/get_sessions_for_date_usecase.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/usecases/reschedule_session_usecase.dart';

/// Controller for Schedule Screen
/// Manages state and business logic for the schedule feature
class ScheduleController extends GetxController {
  final ScheduleRepository repository;

  ScheduleController({required this.repository});

  // Observable states
  final RxList<SessionEntity> sessions = <SessionEntity>[].obs;
  final Rx<ScheduleSummaryEntity?> summary = Rx<ScheduleSummaryEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  // Selected date tracking
  final RxInt selectedDayIndex = 3.obs; // Tuesday 22 highlighted by default
  final RxBool showCalendar = false.obs;
  final RxInt selectedCalendarDay = 16.obs;

  // Day labels for timeline
  final List<String> dayLabels = ['Tue', 'Tue', 'Tue', 'Tue', 'Tue', 'Tue'];
  final List<int> dayNumbers = [19, 19, 19, 22, 23, 24];
  final List<bool> hasDot = [false, false, false, true, false, false];

  // Use cases
  late GetSessionsForDateUseCase _getSessionsForDate;
  late GetScheduleSummaryUseCase _getScheduleSummary;
  late GetSessionDetailsUseCase _getSessionDetails;
  late CancelSessionUseCase _cancelSession;
  late RescheduleSessionUseCase _rescheduleSession;

  @override
  void onInit() {
    super.onInit();
    _initializeUseCases();
    loadSchedule();
  }

  void _initializeUseCases() {
    _getSessionsForDate = GetSessionsForDateUseCase(repository);
    _getScheduleSummary = GetScheduleSummaryUseCase(repository);
    _getSessionDetails = GetSessionDetailsUseCase(repository);
    _cancelSession = CancelSessionUseCase(repository);
    _rescheduleSession = RescheduleSessionUseCase(repository);
  }

  /// Load schedule data
  Future<void> loadSchedule() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load sessions and summary in parallel
      await Future.wait([
        _loadSessions(),
        _loadSummary(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load schedule');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh schedule data
  Future<void> refreshSchedule() async {
    try {
      isRefreshing.value = true;
      await loadSchedule();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _loadSessions() async {
    // For now, load mock data - selected day index 3 has sessions
    if (selectedDayIndex.value == 3) {
      final sessionsData = await _getSessionsForDate(DateTime.now());
      sessions.value = sessionsData;
    } else {
      sessions.value = [];
    }
  }

  Future<void> _loadSummary() async {
    final summaryData = await _getScheduleSummary(DateTime.now());
    summary.value = summaryData;
  }

  /// Select a day in the timeline
  void selectDay(int index) {
    selectedDayIndex.value = index;
    _loadSessions().catchError((e) {
      errorMessage.value = 'Failed to load sessions. Please try again.';
    });
  }

  /// Toggle calendar view
  void toggleCalendarView() {
    showCalendar.value = !showCalendar.value;
  }

  /// Select a day in the calendar
  void selectCalendarDay(int day) {
    selectedCalendarDay.value = day;
  }

  /// Get session details
  Future<SessionEntity?> getSessionDetails(String sessionId) async {
    try {
      return await _getSessionDetails(sessionId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load session details');
      return null;
    }
  }

  /// Cancel a session
  Future<bool> cancelSession(String sessionId) async {
    try {
      await _cancelSession(sessionId);
      Get.snackbar('Success', 'Session cancelled successfully');
      await _loadSessions();
      await _loadSummary();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel session');
      return false;
    }
  }

  /// Reschedule a session
  Future<bool> rescheduleSession(
    String sessionId,
    DateTime newDate,
    String newTime,
  ) async {
    try {
      await _rescheduleSession(sessionId, newDate, newTime);
      Get.snackbar('Success', 'Session rescheduled successfully');
      await _loadSessions();
      await _loadSummary();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to reschedule session');
      return false;
    }
  }

  /// Start a call session
  Future<void> startCallSession(String sessionId) async {
    try {
      await repository.startCallSession(sessionId);
      Get.snackbar('Success', 'Starting call...');
    } catch (e) {
      Get.snackbar('Error', 'Failed to start call');
    }
  }

  /// Send message to client
  Future<void> sendMessageToClient(String clientId, String message) async {
    try {
      await repository.sendMessageToClient(clientId, message);
      Get.snackbar('Success', 'Message sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  /// Check if selected day has sessions
  bool get hasSessions => sessions.isNotEmpty;

  /// Get session count for selected day
  int get sessionCount => sessions.length;
}
