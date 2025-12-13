import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  List<GoalModel> _goals = [];

  List<GoalModel> get goals => _goals;

  void listenToGoals() {
    _goalService.fetchGoals().listen((goalList) {
      _goals = goalList;
      notifyListeners();
    });
  }

  Future<String?> addGoal(GoalModel goal) async {
    return await _goalService.addGoal(goal);
  }

  Future<String?> updateGoal(GoalModel goal) async {
    return await _goalService.updateGoal(goal);
  }
}
