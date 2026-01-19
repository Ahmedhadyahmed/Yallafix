import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsAndServicesScreen extends StatefulWidget {
  const TermsAndServicesScreen({super.key});

  @override
  State<TermsAndServicesScreen> createState() => _TermsAndServicesScreenState();
}

class _TermsAndServicesScreenState extends State<TermsAndServicesScreen> {
  int selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool showBackToTop = false;

  final List<String> tabs = [
    'Terms of Service',
    'Privacy Policy',
    'Service Agreement',
    'Refund Policy',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200) {
      if (!showBackToTop) {
        setState(() {
          showBackToTop = true;
        });
      }
    } else {
      if (showBackToTop) {
        setState(() {
          showBackToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF8C00)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Services',
          style: TextStyle(
            color: Color(0xFFFF8C00),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFFF8C00)),
            onPressed: _shareTerms,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: tabs.asMap().entries.map((entry) {
                int index = entry.key;
                String title = entry.value;
                bool isSelected = selectedTabIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                      _scrollToTop();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF8C00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: showBackToTop
          ? FloatingActionButton.small(
        onPressed: _scrollToTop,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildTermsOfService();
      case 1:
        return _buildPrivacyPolicy();
      case 2:
        return _buildServiceAgreement();
      case 3:
        return _buildRefundPolicy();
      default:
        return _buildTermsOfService();
    }
  }

  Widget _buildTermsOfService() {
    return _buildSection([
      _buildSectionHeader('Terms of Service'),
      _buildLastUpdated('Last updated: November 2024'),

      _buildSubsection('1. Acceptance of Terms', [
        'By using our automotive services app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
        'These terms apply to all users of the service, including customers requesting automotive services and service providers.'
      ]),

      _buildSubsection('2. Description of Service', [
        'Our platform connects users with various automotive service providers including:',
        '• Emergency roadside assistance',
        '• Towing services',
        '• Mobile mechanics',
        '• Battery replacement and jump-start services',
        '• Auto parts delivery',
        '• Vehicle diagnostics and repairs'
      ]),

      _buildSubsection('3. User Responsibilities', [
        'Users must provide accurate information when requesting services.',
        'Payment for services must be made through the approved payment methods.',
        'Users must be present at the specified location during the service window.',
        'Any damage to service provider equipment may result in additional charges.'
      ]),

      _buildSubsection('4. Service Provider Responsibilities', [
        'Service providers must be licensed and insured as required by local regulations.',
        'Services must be performed in a professional and timely manner.',
        'Service providers must maintain appropriate certifications and qualifications.',
        'All work must comply with industry standards and safety regulations.'
      ]),

      _buildSubsection('5. Payment Terms', [
        'Payment is due upon completion of services unless otherwise agreed.',
        'All prices are subject to change based on service complexity and location.',
        'Additional fees may apply for emergency services or after-hours requests.',
        'Refunds are subject to our refund policy outlined in a separate section.'
      ]),

      _buildSubsection('6. Limitation of Liability', [
        'Our platform acts as an intermediary between users and service providers.',
        'We are not liable for the quality of work performed by independent service providers.',
        'Users acknowledge that automotive services carry inherent risks.',
        'Our liability is limited to the amount paid for the specific service in question.'
      ]),

      _buildSubsection('7. Termination', [
        'We reserve the right to terminate accounts that violate these terms.',
        'Users may terminate their account at any time through the app settings.',
        'Upon termination, access to the platform and services will be discontinued.'
      ])
    ]);
  }

  Widget _buildPrivacyPolicy() {
    return _buildSection([
      _buildSectionHeader('Privacy Policy'),
      _buildLastUpdated('Last updated: November 2024'),

      _buildSubsection('Information We Collect', [
        'Personal Information: Name, email address, phone number, and payment information.',
        'Location Data: GPS coordinates to connect you with nearby service providers.',
        'Vehicle Information: Make, model, year, and service history for better assistance.',
        'Usage Data: App interactions, service requests, and feedback.'
      ]),

      _buildSubsection('How We Use Your Information', [
        'To connect you with appropriate automotive service providers',
        'To process payments and maintain service records',
        'To improve our services and user experience',
        'To send important notifications about your service requests',
        'To comply with legal obligations and resolve disputes'
      ]),

      _buildSubsection('Information Sharing', [
        'We share necessary information with service providers to fulfill your requests.',
        'Payment information is shared with secure payment processors.',
        'We may share anonymized data for analytics and service improvement.',
        'We do not sell personal information to third parties.'
      ]),

      _buildSubsection('Data Security', [
        'We use industry-standard encryption to protect your data.',
        'Access to personal information is limited to authorized personnel.',
        'Regular security audits are conducted to maintain data protection.',
        'Users are responsible for maintaining the security of their account credentials.'
      ]),

      _buildSubsection('Your Rights', [
        'Access: You can request access to your personal information.',
        'Correction: You can update incorrect information in your profile.',
        'Deletion: You can request deletion of your account and associated data.',
        'Portability: You can request a copy of your data in a readable format.'
      ])
    ]);
  }

  Widget _buildServiceAgreement() {
    return _buildSection([
      _buildSectionHeader('Service Agreement'),
      _buildLastUpdated('Last updated: November 2024'),

      _buildSubsection('Service Scope', [
        'Emergency roadside assistance available 24/7 in covered areas.',
        'Towing services for disabled vehicles to specified locations.',
        'Mobile mechanic services for on-site repairs and diagnostics.',
        'Battery services including testing, jump-starts, and replacements.'
      ]),

      _buildSubsection('Response Times', [
        'Emergency services: Target response within 30-60 minutes.',
        'Scheduled services: Confirmed appointment times with 15-minute windows.',
        'Weather and traffic conditions may affect response times.',
        'Users will be notified of any delays via app notifications.'
      ]),

      _buildSubsection('Service Areas', [
        'Services available in major metropolitan areas and highways.',
        'Rural area coverage may be limited and subject to additional fees.',
        'Service area maps are available in the app for reference.',
        'We continuously work to expand our coverage areas.'
      ]),

      _buildSubsection('Quality Assurance', [
        'All service providers undergo background checks and training.',
        'Customer feedback is monitored and used for quality improvement.',
        'Service providers must maintain minimum rating standards.',
        'Complaints are investigated promptly and resolved fairly.'
      ]),

      _buildSubsection('Warranties', [
        'Parts installed carry manufacturer warranties where applicable.',
        'Labor warranties vary by service type and provider.',
        'Warranty terms are clearly communicated before service begins.',
        'Warranty claims must be reported within specified time frames.'
      ])
    ]);
  }

  Widget _buildRefundPolicy() {
    return _buildSection([
      _buildSectionHeader('Refund Policy'),
      _buildLastUpdated('Last updated: November 2024'),

      _buildSubsection('Refund Eligibility', [
        'Services not performed as agreed may be eligible for full refund.',
        'Cancellations made more than 2 hours before scheduled service time.',
        'Technical issues preventing service completion due to app malfunction.',
        'Service provider no-shows without valid justification.'
      ]),

      _buildSubsection('Refund Process', [
        'Refund requests must be submitted within 48 hours of service.',
        'All requests are reviewed by our customer service team.',
        'Approved refunds are processed within 3-5 business days.',
        'Refunds are issued to the original payment method used.'
      ]),

      _buildSubsection('Non-Refundable Situations', [
        'Services successfully completed as requested.',
        'Cancellations made less than 2 hours before service time.',
        'Customer unavailability at the scheduled service location.',
        'Additional services requested beyond the original scope.'
      ]),

      _buildSubsection('Partial Refunds', [
        'May be issued for partially completed services.',
        'Calculated based on the percentage of service completed.',
        'Parts used or installed are typically non-refundable.',
        'Labor charges may be prorated based on time spent.'
      ]),

      _buildSubsection('Dispute Resolution', [
        'Customers can file disputes through the app or customer service.',
        'All disputes are investigated thoroughly and fairly.',
        'Mediation services available for complex disputes.',
        'Final decisions are communicated within 7 business days.'
      ])
    ]);
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF8C00),
        ),
      ),
    );
  }

  Widget _buildLastUpdated(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSubsection(String title, List<String> content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _shareTerms() {
    String shareText = '''
Check out the Terms and Services for our Automotive Services App!

📱 Professional automotive services at your fingertips
🔧 Licensed and insured service providers
🚗 24/7 emergency roadside assistance
⚡ Fast, reliable, and transparent

Download the app today!
    ''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms information copied to clipboard!'),
        backgroundColor: Color(0xFFFF8C00),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}