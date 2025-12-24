import 'package:flutter/material.dart';

/// Singleton service to manage activities across the app
/// This allows Services page and Activity page to share data
class ActivityManager {
  // Singleton instance
  static final ActivityManager _instance = ActivityManager._internal();
  factory ActivityManager() => _instance;
  ActivityManager._internal();

  // List of all activities (will be modified from different screens)
  final List<ActivityItemData> _activities = [];

  // Listeners for activity changes
  final List<VoidCallback> _listeners = [];

  /// Get all activities
  List<ActivityItemData> get activities => List.unmodifiable(_activities);

  /// Add a new activity
  void addActivity(ActivityItemData activity) {
    _activities.insert(0, activity); // Add to beginning (most recent first)
    _notifyListeners();
  }

  /// Update an existing activity
  void updateActivity(String id, ActivityItemData updatedActivity) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _activities[index] = updatedActivity;
      _notifyListeners();
    }
  }

  /// Remove an activity
  void removeActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    _notifyListeners();
  }

  /// Add listener for activity changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of changes
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  /// Generate unique ID for new activity
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Activity status enum
enum ActivityStatus { upcoming, completed, cancelled }

/// Model class representing an activity item
class ActivityItemData {
  final String id;
  final String serviceName;
  final String date;
  ActivityStatus status;
  final String price;
  final double? rating;
  final String description;
  final String serviceProvider;
  String? comments;
  final String? location; // Added location field
  final String? paymentMethod; // Added payment method field

  ActivityItemData({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.status,
    required this.price,
    this.rating,
    required this.description,
    required this.serviceProvider,
    this.comments,
    this.location,
    this.paymentMethod,
  });

  /// Returns human-readable status text
  String get statusText {
    switch (status) {
      case ActivityStatus.upcoming:
        return 'Upcoming';
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Returns appropriate color for each status
  Color get statusColor {
    switch (status) {
      case ActivityStatus.upcoming:
        return Colors.orange;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.cancelled:
        return Colors.red;
    }
  }
}