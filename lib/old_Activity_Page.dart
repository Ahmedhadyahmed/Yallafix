/*
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filterOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips section
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: List.generate(_filterOptions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_filterOptions[index]),
                    selected: _selectedFilterIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilterIndex = selected ? index : 0;
                      });
                    },
                    selectedColor: const Color(0xFFFF8C00),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedFilterIndex == index ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: _selectedFilterIndex == index ? const Color(0xFFFF8C00) : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ActivityItem(
                  serviceName: 'Tow Service',
                  date: 'Today, 10:30 AM',
                  status: 'Completed',
                  price: '250 EGP',
                  rating: 4.7,
                ),
                SizedBox(height: 16),
                ActivityItem(
                  serviceName: 'Battery Service',
                  date: 'Yesterday, 2:15 PM',
                  status: 'Completed',
                  price: '125 EGP',
                  rating: 4.9,
                ),
                SizedBox(height: 16),
                ActivityItem(
                  serviceName: 'Mobile Mechanic',
                  date: 'Oct 12, 11:00 AM',
                  status: 'Completed',
                  price: '375 EGP',
                  rating: 4.8,
                ),
                SizedBox(height: 16),
                ActivityItem(
                  serviceName: 'Auto Parts',
                  date: 'Oct 10, 4:45 PM',
                  status: 'Cancelled',
                  price: '150 EGP',
                  rating: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String serviceName;
  final String date;
  final String status;
  final String price;
  final double? rating;

  const ActivityItem({
    super.key,
    required this.serviceName,
    required this.date,
    required this.status,
    required this.price,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Completed'
                      ? Colors.green.withOpacity(0.2)
                      : status == 'Cancelled'
                      ? Colors.red.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Completed'
                        ? Colors.green
                        : status == 'Cancelled'
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFF8C00),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

 */