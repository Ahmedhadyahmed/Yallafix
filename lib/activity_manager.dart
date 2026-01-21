import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Activity Status Enum
enum ActivityStatus {
  completed,
  cancelled,
  upcoming,
}

// Activity Data Model
class ActivityItemData {
  String id;
  String serviceName;
  String date;
  ActivityStatus status;
  String price;
  double? rating;
  String description;
  String serviceProvider;
  String? comments;
  String? location;
  String? paymentMethod;

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

  // Get status as text
  String get statusText {
    switch (status) {
      case ActivityStatus.completed:
        return 'Completed';
      case ActivityStatus.cancelled:
        return 'Cancelled';
      case ActivityStatus.upcoming:
        return 'Upcoming';
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'date': date,
      'status': status.index,
      'price': price,
      'rating': rating,
      'description': description,
      'serviceProvider': serviceProvider,
      'comments': comments,
      'location': location,
      'paymentMethod': paymentMethod,
    };
  }

  // Create from JSON
  factory ActivityItemData.fromJson(Map<String, dynamic> json) {
    return ActivityItemData(
      id: json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      date: json['date'] ?? '',
      status: ActivityStatus.values[json['status'] ?? 0],
      price: json['price'] ?? '\$0.00',
      rating: json['rating']?.toDouble(),
      description: json['description'] ?? '',
      serviceProvider: json['serviceProvider'] ?? '',
      comments: json['comments'],
      location: json['location'],
      paymentMethod: json['paymentMethod'],
    );
  }
}

// Activity Manager - Singleton
class ActivityManager extends ChangeNotifier {
  static final ActivityManager _instance = ActivityManager._internal();
  factory ActivityManager() => _instance;
  ActivityManager._internal();

  static const String _storageKey = 'saved_activities';
  List<ActivityItemData> _activities = [];
  bool _isInitialized = false;

  List<ActivityItemData> get activities => List.unmodifiable(_activities);
  bool get isInitialized => _isInitialized;

  // Initialize and load activities from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? activitiesJson = prefs.getString(_storageKey);

      if (activitiesJson != null && activitiesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(activitiesJson);
        _activities = decoded.map((item) => ActivityItemData.fromJson(item)).toList();
        print('✅ Loaded ${_activities.length} activities from storage');
      } else {
        print('ℹ️ No saved activities found');
        _activities = [];
      }
    } catch (e) {
      print('❌ Error loading activities: $e');
      _activities = [];
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save activities to storage
  Future<void> _saveActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> activitiesJson =
      _activities.map((activity) => activity.toJson()).toList();
      final String encoded = json.encode(activitiesJson);
      await prefs.setString(_storageKey, encoded);
      print('💾 Saved ${_activities.length} activities to storage');
    } catch (e) {
      print('❌ Error saving activities: $e');
    }
  }

  // Add new activity
  Future<void> addActivity(ActivityItemData activity) async {
    _activities.insert(0, activity); // Add to beginning (most recent first)
    notifyListeners();
    await _saveActivities();
    print('➕ Added activity: ${activity.serviceName}');
  }

  // Update existing activity
  Future<void> updateActivity(String id, ActivityItemData updatedActivity) async {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _activities[index] = updatedActivity;
      notifyListeners();
      await _saveActivities();
      print('✏️ Updated activity: ${updatedActivity.serviceName}');
    }
  }

  // Delete activity
  Future<void> deleteActivity(String id) async {
    final initialLength = _activities.length;
    _activities.removeWhere((a) => a.id == id);
    if (_activities.length < initialLength) {
      notifyListeners();
      await _saveActivities();
      print('🗑️ Deleted activity with id: $id');
    }
  }

  // Clear all activities
  Future<void> clearAllActivities() async {
    _activities.clear();
    notifyListeners();
    await _saveActivities();
    print('🗑️ Cleared all activities');
  }

  // Generate unique ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get total spent (only completed activities)
  double getTotalSpent() {
    return _activities
        .where((a) => a.status == ActivityStatus.completed)
        .fold(0.0, (sum, activity) {
      final priceStr = activity.price.replaceAll(RegExp(r'[^\d.]'), '');
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  // Get total number of services
  int getTotalServices() {
    return _activities.length;
  }
}