import 'package:flutter/material.dart';
import 'live_chat.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFFD19700);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // FAQ + Contact
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help Center",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 10),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // Search + filter
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              "Search for help",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black),
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "FAQ"),
                  Tab(text: "Contact"),
                ],
              ),
              const Divider(height: 1, color: Colors.grey),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // FAQ Tab
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildExpansionTile(
                "How do I manage my notifications?",
                "To manage notifications, go to \"Settings,\" select \"Notification Settings,\" and customize your preferences.",
              ),
              _buildExpansionTile(
                "How do I start a guided meditation session?",
                "Go to the Meditation section and select a guided session of your choice.",
              ),
              _buildExpansionTile(
                "How do I join a support group?",
                "Navigate to the Community section, then select a group that fits your interests.",
              ),
              _buildExpansionTile(
                "Is my data safe and private?",
                "Yes, we prioritize your privacy and follow strict security protocols.",
              ),
            ],
          ),

          // Contact Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Icon(Icons.email, color: primaryColor),
                title: const Text("Email Us"),
                subtitle: const Text("support@example.com"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.phone, color: primaryColor),
                title: const Text("Call Us"),
                subtitle: const Text("+1 234 567 890"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.chat, color: primaryColor),
                title: const Text("Live Chat"),
                subtitle: const Text("Chat with our support team"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LiveChatScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        iconColor: primaryColor,
        collapsedIconColor: primaryColor,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(content, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
