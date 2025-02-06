import 'package:get/get.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class TaskController extends GetxController {
  final RxList<Task> _tasks = <Task>[].obs;
  final RxBool _isLoading = false.obs;
  final Rxn<String> _error = Rxn<String>();

  late final ApiService _apiService;

  List<Task> get tasks => _tasks.toList();
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  TaskController() {
    _apiService = ApiService(Get.find<AuthController>());
    loadTasks();
  }

  Future<void> loadTasks() async {
    await _performOperation(() async {
      _tasks.value = await _apiService.getTasks();
    }, errorMessage: 'Error loading tasks');
  }

  Future<void> addTask(Task task) async {
    await _performOperation(() async {
      final newTask = await _apiService.createTask(task);
      _tasks.add(newTask);
    }, errorMessage: 'Error adding task');
  }

  Future<void> updateTask(Task updatedTask) async {
    await _performOperation(() async {
      final task = await _apiService.updateTask(updatedTask);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
    }, errorMessage: 'Error updating task');
  }

  Future<void> deleteTask(String taskId) async {
    await _performOperation(() async {
      await _apiService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
    }, errorMessage: 'Error deleting task');
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    await _performOperation(() async {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final updatedTask = _tasks[index].copyWith(
          completed: !_tasks[index].completed,
          completedAt: !_tasks[index].completed
              ? DateTime.now().toIso8601String()
              : null,
        );
        await updateTask(updatedTask);
      }
    }, errorMessage: 'Error toggling task completion');
  }

  void initializeWithTasks(List<Task> initialTasks) {
    _tasks.value = initialTasks;
  }

  Future<void> _performOperation(Future<void> Function() operation,
      {required String errorMessage}) async {
    _setLoading(true);
    _clearError();
    try {
      await operation();
    } catch (e) {
      _setError('$errorMessage: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  void _setError(String errorMessage) {
    _error.value = errorMessage;
  }

  void _clearError() {
    _error.value = null;
  }
}
