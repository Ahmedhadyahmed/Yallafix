import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme_Provider.dart';
import 'activity_manager.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeActivities();
    ActivityManager().addListener(_onActivitiesChanged);
  }

  Future<void> _initializeActivities() async {
    setState(() => _isLoading = true);
    await ActivityManager().initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onActivitiesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    ActivityManager().removeListener(_onActivitiesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final activities = ActivityManager().activities;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF221910) : const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFF48C25),
                ),
              )
                  : activities.isEmpty
                  ? _buildEmptyState(isDark)
                  : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildStatsCards(isDark),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Past Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF181411),
                            ),
                          ),
                          if (activities.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _showClearAllDialog(isDark),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Clear All'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...activities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildActivityCard(activity, isDark),
                      )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Activities Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181411),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your service history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF181411),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your service history',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221910) : const Color(0xFFF8F7F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : const Color(0xFF181411),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final totalSpent = ActivityManager().getTotalSpent();
    final totalServices = ActivityManager().getTotalServices();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFFF48C25),
            iconBgColor: const Color(0xFFF48C25).withOpacity(0.1),
            label: 'TOTAL SPENT',
            value: '\$${totalSpent.toStringAsFixed(2)}',
            isDark: isDark,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            icon: Icons.history,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFF2563EB).withOpacity(0.1),
            label: 'SERVICES',
            value: '$totalServices',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181411),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItemData activity, bool isDark) {
    return Dismissible(
      key: Key(activity.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(activity, isDark),
      child: GestureDetector(
        onTap: () => _showActivityDetails(activity, isDark),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF32281E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getServiceIconBgColor(activity.serviceName),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getServiceIcon(activity.serviceName),
                      color: _getServiceIconColor(activity.serviceName),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.serviceName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF181411),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.date,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(activity.status),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Toyota Camry',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF181411),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    activity.price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: activity.status == ActivityStatus.cancelled
                          ? (isDark ? Colors.white : Colors.black).withOpacity(0.4)
                          : const Color(0xFFF48C25),
                      decoration: activity.status == ActivityStatus.cancelled
                          ? TextDecoration.lineThrough
                          : null,
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

  Future<bool?> _showDeleteConfirmation(ActivityItemData activity, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF32281E) : Colors.white,
        title: Text(
          'Delete Activity',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF181411),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${activity.serviceName}"?',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ActivityManager().deleteActivity(activity.id);
              if (context.mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${activity.serviceName} deleted'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF32281E) : Colors.white,
        title: Text(
          'Clear All Activities',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF181411),
          ),
        ),
        content: Text(
          'Are you sure you want to delete all activities? This action cannot be undone.',
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ActivityManager().clearAllActivities();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All activities cleared'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ActivityStatus status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case ActivityStatus.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = 'COMPLETED';
        break;
      case ActivityStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        text = 'CANCELED';
        break;
      case ActivityStatus.upcoming:
        bgColor = const Color(0xFFDCEEFF);
        textColor = const Color(0xFF1E40AF);
        text = 'UPCOMING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'towing service':
      case 'towing':
        return Icons.local_shipping;
      case 'oil change':
        return Icons.water_drop;
      case 'tire change':
      case 'flat tire change':
        return Icons.tire_repair;
      case 'diagnostics':
        return Icons.query_stats;
      case 'jump start':
        return Icons.battery_charging_full;
      case 'ac repair':
        return Icons.ac_unit;
      case 'mechanic':
        return Icons.build;
      default:
        return Icons.build;
    }
  }

  Color _getServiceIconColor(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'towing service':
      case 'towing':
        return const Color(0xFFF48C25);
      case 'oil change':
        return const Color(0xFF3B82F6);
      case 'tire change':
      case 'flat tire change':
        return const Color(0xFF6B7280);
      case 'diagnostics':
        return const Color(0xFF9333EA);
      case 'jump start':
        return const Color(0xFFEAB308);
      case 'ac repair':
        return const Color(0xFF00BCD4);
      case 'mechanic':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getServiceIconBgColor(String serviceName) {
    return _getServiceIconColor(serviceName).withOpacity(0.1);
  }

  void _showActivityDetails(ActivityItemData activity, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityDetailsSheet(
        activity: activity,
        isDark: isDark,
        onCancel: (String? comment) async {
          final manager = ActivityManager();
          final activities = manager.activities;
          final idx = activities.indexWhere((a) => a.id == activity.id);

          if (idx != -1) {
            final updatedActivity = ActivityItemData(
              id: activity.id,
              serviceName: activity.serviceName,
              date: activity.date,
              status: ActivityStatus.cancelled,
              price: activity.price,
              rating: activity.rating,
              description: activity.description,
              serviceProvider: activity.serviceProvider,
              comments: comment,
              location: activity.location,
              paymentMethod: activity.paymentMethod,
            );
            await manager.updateActivity(activity.id, updatedActivity);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking cancelled'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onDelete: () async {
          await ActivityManager().deleteActivity(activity.id);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${activity.serviceName} deleted'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

class ActivityDetailsSheet extends StatelessWidget {
  final ActivityItemData activity;
  final bool isDark;
  final void Function(String? comment)? onCancel;
  final VoidCallback? onDelete;

  const ActivityDetailsSheet({
    super.key,
    required this.activity,
    required this.isDark,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF32281E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.serviceName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF181411),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Activity',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.serviceProvider,
                  style: TextStyle(
                    fontSize: 16,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
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
                if (activity.location != null)
                  _buildDetailRow('Location', activity.location!),
                if (activity.paymentMethod != null)
                  _buildDetailRow('Payment', activity.paymentMethod!),
                _buildDetailRow('Comments', activity.comments ?? '-'),
                const SizedBox(height: 20),
                if (activity.status == ActivityStatus.upcoming)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final cancelCallback = onCancel;

                        final comment = await showDialog<String?>(
                          context: context,
                          builder: (dialogContext) {
                            final commentController = TextEditingController();
                            return AlertDialog(
                              backgroundColor: isDark ? const Color(0xFF32281E) : Colors.white,
                              title: Text(
                                'Cancel Booking',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF181411),
                                ),
                              ),
                              content: TextField(
                                controller: commentController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF181411),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Optional comment / reason',
                                  hintStyle: TextStyle(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                                  ),
                                ),
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(null),
                                  child: Text(
                                    'Dismiss',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final text = commentController.text.trim();
                                    Navigator.of(dialogContext).pop(text.isEmpty ? null : text);
                                  },
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(color: Color(0xFFF48C25)),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (cancelCallback != null) {
                          cancelCallback(comment);
                        }
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
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF181411),
              ),
            ),
          ),
        ],
      ),
    );
  }
}