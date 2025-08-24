import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  final List<Message> messages = [
    Message(
      sender: 'Tow Service Team',
      preview: 'Your tow truck is on the way! ETA: 15 min',
      time: '10:30 AM',
      isRead: true,
      category: 'Service',
      avatar: Icons.local_shipping,
    ),
    Message(
      sender: 'Battery Service',
      preview: 'Your battery replacement is complete. How was our service?',
      time: 'Yesterday',
      isRead: false,
      category: 'Service',
      avatar: Icons.battery_charging_full,
    ),
    Message(
      sender: 'Auto Parts Delivery',
      preview: 'Your ordered parts have been shipped',
      time: 'Oct 12',
      isRead: true,
      category: 'Service',
      avatar: Icons.inventory,
    ),
    Message(
      sender: 'Mobile Mechanic',
      preview: 'Thank you for choosing our service!',
      time: 'Oct 10',
      isRead: true,
      category: 'Service',
      avatar: Icons.build,
    ),
    Message(
      sender: 'Customer Support',
      preview: 'How can we help you with your recent service?',
      time: 'Oct 8',
      isRead: false,
      category: 'Support',
      avatar: Icons.support_agent,
    ),
  ];

  List<Message> get filteredMessages {
    List<Message> filtered = messages;

    // Apply category filter
    if (selectedFilter != 'All') {
      if (selectedFilter == 'Unread') {
        filtered = filtered.where((message) => !message.isRead).toList();
      } else {
        filtered = filtered.where((message) => message.category == selectedFilter).toList();
      }
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((message) =>
      message.sender.toLowerCase().contains(searchQuery.toLowerCase()) ||
          message.preview.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void _onMessageTap(Message message) {
    setState(() {
      message.isRead = true;
    });

    // Navigate to message detail screen or show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message.sender),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time: ${message.time}'),
              const SizedBox(height: 8),
              Text(message.preview),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement reply functionality
                _showReplyDialog(message);
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  void _showReplyDialog(Message message) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to ${message.sender}'),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(
              hintText: 'Type your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  // Here you would typically send the reply
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reply sent!')),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: isSearching
            ? TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          autofocus: true,
        )
            : const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: const Color(0xFFFF8C00),
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips for message categories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread'),
                const SizedBox(width: 8),
                _buildFilterChip('Service'),
                const SizedBox(width: 8),
                _buildFilterChip('Support'),
              ],
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: filteredMessages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isNotEmpty
                        ? 'No messages found for "$searchQuery"'
                        : selectedFilter == 'All'
                        ? 'No messages yet'
                        : 'No $selectedFilter messages',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredMessages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return MessageItem(
                  message: filteredMessages[index],
                  onTap: () => _onMessageTap(filteredMessages[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFF8C00),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: Colors.grey)),
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = label;
        });
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class Message {
  final String sender;
  final String preview;
  final String time;
  bool isRead;
  final String category;
  final IconData avatar;

  Message({
    required this.sender,
    required this.preview,
    required this.time,
    required this.isRead,
    required this.category,
    required this.avatar,
  });
}

class MessageItem extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const MessageItem({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: !message.isRead
              ? Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with specific icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                message.avatar,
                color: const Color(0xFFFF8C00),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.sender,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: message.isRead ? Colors.black : const Color(0xFFFF8C00),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        message.time,
                        style: TextStyle(
                          color: message.isRead ? Colors.grey[600] : const Color(0xFFFF8C00),
                          fontSize: 12,
                          fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.preview,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (!message.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8C00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}