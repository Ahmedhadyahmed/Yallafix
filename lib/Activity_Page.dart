import 'package:flutter/material.dart';
import 'activity_manager.dart'; // NEW IMPORT

/// ActivityPage displays the user's service activity history
/// Shows upcoming, completed, and cancelled services with filtering and search capabilities
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

/// State class for ActivityPage that manages activity data, filtering, and search
/// Uses TickerProviderStateMixin for animation support
class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {
  // Currently selected filter index (0=All, 1=Upcoming, 2=Completed, 3=Cancelled)
  int _selectedFilterIndex = 0;

  // Available filter options displayed as chips
  final List<String> _filterOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Search functionality state
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Activity data
  List<ActivityItemData> _allActivities = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 300ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Create fade animation from transparent to opaque
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load activities from ActivityManager
    _loadActivitiesFromManager();

    // Listen for activity changes
    ActivityManager().addListener(_onActivitiesChanged);

    // Start fade-in animation
    _animationController.forward();
  }

  // Load activities from ActivityManager
  void _loadActivitiesFromManager() {
    final managerActivities = ActivityManager().activities;

    // If manager has activities, use them; otherwise use mock data
    if (managerActivities.isEmpty) {
      _allActivities = _getMockActivities();
    } else {
      _allActivities = List.from(managerActivities);
    }
  }

  // Called when activities change in ActivityManager
  void _onActivitiesChanged() {
    setState(() {
      _allActivities = List.from(ActivityManager().activities);
    });
  }

  /// Returns a list of mock activities for testing
  List<ActivityItemData> _getMockActivities() {
    return [
      ActivityItemData(
        id: '1',
        serviceName: 'Tow Service',
        date: 'Nov 15, 2025 - 10:00 AM',
        status: ActivityStatus.upcoming,
        price: '\$120.00',
        rating: null,
        description: 'Vehicle towing from downtown to repair shop',
        serviceProvider: 'Quick Tow Services',
        comments: null,
      ),
      ActivityItemData(
        id: '2',
        serviceName: 'Battery Service',
        date: 'Nov 10, 2025 - 2:30 PM',
        status: ActivityStatus.completed,
        price: '\$85.00',
        rating: 4.5,
        description: 'Battery replacement and electrical system check',
        serviceProvider: 'Auto Care Plus',
        comments: null,
      ),
      ActivityItemData(
        id: '3',
        serviceName: 'Mobile Mechanic',
        date: 'Nov 8, 2025 - 9:00 AM',
        status: ActivityStatus.completed,
        price: '\$150.00',
        rating: 5.0,
        description: 'On-site engine diagnostics and minor repairs',
        serviceProvider: 'Mobile Auto Experts',
        comments: null,
      ),
    ];
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _animationController.dispose();
    _searchController.dispose();
    ActivityManager().removeListener(_onActivitiesChanged);
    super.dispose();
  }

  /// Returns filtered activities based on selected filter and search query
  /// Applies both status filter and text search
  List<ActivityItemData> get _filteredActivities {
    List<ActivityItemData> filtered = _allActivities;

    // Apply status filter (All, Upcoming, Completed, Cancelled)
    if (_selectedFilterIndex != 0) {
      // Convert filter index to ActivityStatus enum
      ActivityStatus filterStatus = ActivityStatus.values[_selectedFilterIndex - 1];
      filtered = filtered.where((activity) => activity.status == filterStatus).toList();
    }

    // Apply search filter - searches in service name, provider, and description
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((activity) =>
      activity.serviceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.serviceProvider.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  /// Toggles search mode on/off
  /// Clears search query when exiting search mode
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  /// Simulates refresh with a delay
  Future<void> _refreshActivities() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadActivitiesFromManager();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Flat design
        // Show search field when in search mode, otherwise show title
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true, // Auto-focus when entering search mode
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
            color: Color(0xFFFF8C00), // Brand orange
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Toggle between search and close icon
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filter chips section (All, Upcoming, Completed, Cancelled)
            Container(
              height: 60,
              color: Colors.white,
              child: Column(
                children: [
                  // Horizontal scrollable filter chips
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
                                  // Update selected filter
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
                  // Divider line below filters
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
            // Results count and sort button
            if (_filteredActivities.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display count of filtered activities
                    Text(
                      '${_filteredActivities.length} ${_filteredActivities.length == 1 ? 'activity' : 'activities'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Sort button (functionality not yet implemented)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Add sort functionality
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
            // Activities list with pull-to-refresh
            Expanded(
              child: _filteredActivities.isEmpty
                  ? _buildEmptyState() // Show empty state message
                  : RefreshIndicator(
                color: const Color(0xFFFF8C00),
                onRefresh: _refreshActivities, // Refresh activities on pull
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredActivities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = _filteredActivities[index];
                    // Staggered animation for list items
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

  /// Builds the empty state UI when no activities match the current filter/search
  /// Shows context-appropriate message based on filter and search state
  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    // Determine appropriate message based on context
    if (_searchQuery.isNotEmpty) {
      // Empty state for search with no results
      message = 'No results found';
      subtitle = 'Try adjusting your search terms';
      icon = Icons.search_off;
    } else {
      // Empty state based on selected filter
      switch (_selectedFilterIndex) {
        case 1: // Upcoming filter
          message = 'No upcoming activities';
          subtitle = 'Book a service to see upcoming activities';
          icon = Icons.schedule;
          break;
        case 2: // Completed filter
          message = 'No completed activities';
          subtitle = 'Your completed services will appear here';
          icon = Icons.check_circle_outline;
          break;
        case 3: // Cancelled filter
          message = 'No cancelled activities';
          subtitle = 'Cancelled services will be shown here';
          icon = Icons.cancel_outlined;
          break;
        default: // All filter
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

  /// Shows a modal bottom sheet with detailed activity information
  /// Displays full details and action buttons (cancel/rate)
  void _showActivityDetails(ActivityItemData activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityDetailsSheet(
        activity: activity,
        // Provide a callback so the sheet can request cancellation with an optional comment
        onCancel: (String? comment) {
          setState(() {
            final idx = _allActivities.indexWhere((a) => a.id == activity.id);
            if (idx != -1) {
              // Update the activity status to cancelled and store the comment
              _allActivities[idx].status = ActivityStatus.cancelled;
              _allActivities[idx].comments = comment;

              // Update in ActivityManager as well
              ActivityManager().updateActivity(activity.id, _allActivities[idx]);
            }
          });

          // Show confirmation to the user
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Booking cancelled'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Simple undo: set back to upcoming and clear comment
                setState(() {
                  final idx = _allActivities.indexWhere((a) => a.id == activity.id);
                  if (idx != -1) {
                    _allActivities[idx].status = ActivityStatus.upcoming;
                    _allActivities[idx].comments = null;

                    // Update in ActivityManager
                    ActivityManager().updateActivity(activity.id, _allActivities[idx]);
                  }
                });
              },
            ),
          ));
        },
      ),
    );
  }
}

/// Widget that displays an enhanced activity item card
/// Shows service info, status, date, rating, and price
class EnhancedActivityItem extends StatelessWidget {
  final ActivityItemData data;
  final VoidCallback? onTap; // Callback when card is tapped

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
              // Header row with icon, service name, and status badge
              Row(
                children: [
                  // Service icon with background
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
                  // Service name and provider
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
                  // Status badge with colored background
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
              // Service description
              Text(
                data.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              // Footer row with date, rating, and price
              Row(
                children: [
                  // Date/time icon and text
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
                  // Rating (only shown if available)
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
                  // Price in brand color
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

  /// Returns appropriate icon based on service name
  /// Maps service types to Material icons
  IconData _getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'tow service':
      case 'tow truck':
        return Icons.local_shipping;
      case 'battery service':
      case 'battery jump':
        return Icons.battery_charging_full;
      case 'mobile mechanic':
      case 'mechanic':
        return Icons.build;
      case 'auto parts':
        return Icons.settings;
      case 'oil change':
        return Icons.opacity;
      case 'tire service':
      case 'tire change':
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
      case 'fuel delivery':
        return Icons.local_gas_station;
      case 'jump start':
        return Icons.flash_on;
      case 'lockout service':
        return Icons.lock_open;
      case 'diagnostic':
        return Icons.search;
      default:
        return Icons.car_repair; // Default icon for unknown services
    }
  }
}

/// Modal bottom sheet that displays detailed activity information
/// Shows all activity details and provides action buttons
class ActivityDetailsSheet extends StatelessWidget {
  final ActivityItemData activity;
  final void Function(String? comment)? onCancel; // Callback invoked when user cancels booking

  const ActivityDetailsSheet({super.key, required this.activity, this.onCancel});

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
          // Drag handle at the top
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
                // Service name header
                Text(
                  activity.serviceName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                // Service provider name
                Text(
                  activity.serviceProvider,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                // Activity details in rows
                _buildDetailRow('ID', activity.id),
                _buildDetailRow('Description', activity.description),
                _buildDetailRow('Date & Time', activity.date),
                _buildDetailRow('Status', activity.statusText),
                _buildDetailRow('Price', activity.price),
                if (activity.rating != null)
                  _buildDetailRow('Rating', '${activity.rating} ⭐'),
                if (activity.location != null)
                  _buildDetailRow('Location', activity.location!),
                if (activity.paymentMethod != null)
                  _buildDetailRow('Payment', activity.paymentMethod!),
                // Show comments if present
                _buildDetailRow('Comments', activity.comments ?? '-'),
                const SizedBox(height: 20),
                // Action buttons based on activity status
                // Cancel button for upcoming activities
                if (activity.status == ActivityStatus.upcoming)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Capture navigator and callback before awaiting to avoid using `context` across
                        // an async gap (fixes `use_build_context_synchronously` lint).
                        final NavigatorState navigator = Navigator.of(context);
                        final cancelCallback = onCancel;

                        // Ask user for an optional cancellation comment before proceeding
                        String? comment = await showDialog<String?>(
                          context: context,
                          builder: (dialogContext) {
                            final TextEditingController commentController = TextEditingController();
                            return AlertDialog(
                              title: const Text('Cancel Booking'),
                              content: TextField(
                                controller: commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Optional comment / reason',
                                ),
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(null),
                                  child: const Text('Dismiss'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(commentController.text.trim().isEmpty ? null : commentController.text.trim()),
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );

                        // Invoke callback to notify parent to update the activity (even if comment is null)
                        if (cancelCallback != null) {
                          cancelCallback(comment);
                        }

                        // Close the bottom sheet after cancellation using captured navigator
                        navigator.pop();
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
                // Rate button for completed activities without rating
                if (activity.status == ActivityStatus.completed && activity.rating == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Add rating functionality
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

  /// Helper method to build a detail row with label and value
  /// Used for displaying activity information in a consistent format
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with fixed width for alignment
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Value that can expand to fill space
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