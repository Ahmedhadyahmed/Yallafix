
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {
  int _selectedFilterIndex = 0;
  final List<String> _filterOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Updated to load from API
  List<ActivityItemData> _allActivities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load activities from API
    _loadActivities();
    _animationController.forward();
  }

  // Load activities from API
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activities = await _loadActivitiesFromApi();
      setState(() {
        _allActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Fetch activities from API
  Future<List<ActivityItemData>> _loadActivitiesFromApi() async {
    try {
      // Updated to use your MockAPI endpoint
      final url = Uri.parse("https://mock-api.net/api/task-two/activities");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> activitiesJson = json.decode(response.body);
        return activitiesJson
            .map((json) => ActivityItemData.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load activities: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching activities: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ActivityItemData> get _filteredActivities {
    List<ActivityItemData> filtered = _allActivities;

    // Apply status filter
    if (_selectedFilterIndex != 0) {
      ActivityStatus filterStatus = ActivityStatus.values[_selectedFilterIndex - 1];
      filtered = filtered.where((activity) => activity.status == filterStatus).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((activity) =>
      activity.serviceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.serviceProvider.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search activities...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : const Text(
          'Activity',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFFFF8C00),
            ),
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
        ),
      )
          : _errorMessage != null
          ? _buildErrorState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Filter Section
            Container(
              height: 60,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filterOptions.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: FilterChip(
                              label: Text(_filterOptions[index]),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedFilterIndex = selected ? index : 0;
                                });
                              },
                              selectedColor: const Color(0xFFFF8C00),
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF666666),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                              backgroundColor: Colors.grey.shade50,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFFFF8C00) : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              elevation: isSelected ? 2 : 0,
                              pressElevation: 4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
            // Results count and sort
            if (_filteredActivities.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredActivities.length} ${_filteredActivities.length == 1 ? 'activity' : 'activities'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Add sort functionality here
                      },
                      icon: const Icon(Icons.sort, size: 16),
                      label: const Text('Sort'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF8C00),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
            // Activities List
            Expanded(
              child: _filteredActivities.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                color: const Color(0xFFFF8C00),
                onRefresh: _loadActivities,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredActivities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = _filteredActivities[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      curve: Curves.easeInOut,
                      child: EnhancedActivityItem(
                        data: activity,
                        onTap: () => _showActivityDetails(activity),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadActivities,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
      message = 'No results found';
      subtitle = 'Try adjusting your search terms';
      icon = Icons.search_off;
    } else {
      switch (_selectedFilterIndex) {
        case 1:
          message = 'No upcoming activities';
          subtitle = 'Book a service to see upcoming activities';
          icon = Icons.schedule;
          break;
        case 2:
          message = 'No completed activities';
          subtitle = 'Your completed services will appear here';
          icon = Icons.check_circle_outline;
          break;
        case 3:
          message = 'No cancelled activities';
          subtitle = 'Cancelled services will be shown here';
          icon = Icons.cancel_outlined;
          break;
        default:
          message = 'No activities yet';
          subtitle = 'Start using our services to see your activity history';
          icon = Icons.history;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(ActivityItemData activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityDetailsSheet(activity: activity),
    );
  }
}

enum ActivityStatus { upcoming, completed, cancelled }

class ActivityItemData {
  final String id;
  final String serviceName;
  final String date;
  final ActivityStatus status;
  final String price;
  final double? rating;
  final String description;
  final String serviceProvider;

  ActivityItemData({
    required this.id,
    required this.serviceName,
    required this.date,
    required this.status,
    required this.price,
    this.rating,
    required this.description,
    required this.serviceProvider,
  });

  // Factory constructor for JSON parsing - updated to handle both string and enum status
  factory ActivityItemData.fromJson(Map<String, dynamic> json) {
    return ActivityItemData(
      id: json['id']?.toString() ?? '',
      serviceName: json['serviceName'] ?? '',
      date: json['date'] ?? '',
      status: _statusFromString(json['status'] ?? 'upcoming'),
      price: json['price'] ?? '',
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString())
          : null,
      description: json['description'] ?? '',
      serviceProvider: json['serviceProvider'] ?? '',
    );
  }

  // Helper method to convert string to ActivityStatus
  static ActivityStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return ActivityStatus.upcoming;
      case 'completed':
        return ActivityStatus.completed;
      case 'cancelled':
        return ActivityStatus.cancelled;
      default:
        return ActivityStatus.upcoming;
    }
  }

  // Convert to JSON (optional, for future use)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'date': date,
      'status': status.toString().split('.').last,
      'price': price,
      'rating': rating,
      'description': description,
      'serviceProvider': serviceProvider,
    };
  }

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

class EnhancedActivityItem extends StatelessWidget {
  final ActivityItemData data;
  final VoidCallback? onTap;

  const EnhancedActivityItem({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getServiceIcon(data.serviceName),
                      color: const Color(0xFFFF8C00),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.serviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          data.serviceProvider,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: data.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.statusText,
                      style: TextStyle(
                        color: data.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.date,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (data.rating != null) ...[
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    data.price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'tow service':
        return Icons.local_shipping;
      case 'battery service':
        return Icons.battery_charging_full;
      case 'mobile mechanic':
        return Icons.build;
      case 'auto parts':
        return Icons.settings;
      case 'oil change':
        return Icons.opacity;
      case 'tire service':
        return Icons.tire_repair;
      case 'car wash':
        return Icons.local_car_wash;
      case 'ac service':
        return Icons.ac_unit;
      case 'brake service':
        return Icons.speed;
      case 'engine tune-up':
        return Icons.tune;
      case 'windshield repair':
        return Icons.visibility;
      case 'transmission service':
        return Icons.settings_applications;
      case 'emergency fuel':
        return Icons.local_gas_station;
      case 'jump start':
        return Icons.flash_on;
      case 'lockout service':
        return Icons.lock_open;
      default:
        return Icons.car_repair;
    }
  }
}

class ActivityDetailsSheet extends StatelessWidget {
  final ActivityItemData activity;

  const ActivityDetailsSheet({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.serviceName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.serviceProvider,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('ID', activity.id),
                _buildDetailRow('Description', activity.description),
                _buildDetailRow('Date & Time', activity.date),
                _buildDetailRow('Status', activity.statusText),
                _buildDetailRow('Price', activity.price),
                if (activity.rating != null)
                  _buildDetailRow('Rating', '${activity.rating} ⭐'),
                const SizedBox(height: 20),
                if (activity.status == ActivityStatus.upcoming)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add cancel/modify functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ),
                if (activity.status == ActivityStatus.completed && activity.rating == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add rating functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Rate Service'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
