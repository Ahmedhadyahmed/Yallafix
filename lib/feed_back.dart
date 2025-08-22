import 'package:flutter/material.dart';

void main() {
  runApp(const FeedbackApp());
}

const kBrand = Color(0xFFD48921);

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrand,
          primary: kBrand,
        ),
        useMaterial3: true,
      ),
      home: const FeedbackScreen(),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final List<String> emojis = ['😫', '😟', '🙂', '😃', '😍'];
  int? selectedRating; // 0..4
  final issues = const [
    'App Crashes & Freezing',
    'Poor Photo Quality',
    'GPS Tracking Issues',
    'Slow Performance',
  ];
  final Set<String> selectedIssues = {};
  bool needQuickSupport = false;
  final TextEditingController commentCtrl = TextEditingController();

  bool get canSubmit =>
      (selectedRating != null) ||
          selectedIssues.isNotEmpty ||
          commentCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 64,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE7A24A), // فاتح من نفس التدرّج
                kBrand,            // اللون المطلوب #d48921
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card header (يشبه الشكل في الصورة)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share your feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      )),
                  const SizedBox(height: 6),
                  Text('Rate your experience',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      )),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(emojis.length, (i) {
                      final isActive = selectedRating == i;
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive ? kBrand : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            emojis[i],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "PLEASE SELECT THE ISSUES YOU'VE EXPERIENCED",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: .4,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Issues
                  ...issues.map((title) => _IssueTile(
                    title: title,
                    selected: selectedIssues.contains(title),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selectedIssues.add(title);
                        } else {
                          selectedIssues.remove(title);
                        }
                      });
                    },
                  )),

                  const SizedBox(height: 8),
                  // Quick support + label
                  Row(
                    children: [
                      const Text(
                        'Your Comment',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                        value: needQuickSupport,
                        fillColor:
                        WidgetStatePropertyAll(kBrand.withOpacity(.9)),
                        onChanged: (v) =>
                            setState(() => needQuickSupport = v ?? false),
                      ),
                      const Text(
                        'Need Quick Support',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Comment box
                  TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Describe your experience here',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: kBrand, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            canSubmit ? kBrand : Colors.grey.shade300),
                        foregroundColor: WidgetStatePropertyAll(
                            canSubmit ? Colors.white : Colors.grey.shade600),
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 14)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18))),
                      ),
                      onPressed: canSubmit
                          ? () {
                        // TODO: أربط الإرسال بـ API أو أي لوجك
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Submitted. Rating: ${selectedRating != null ? emojis[selectedRating!] : 'N/A'} | Issues: ${selectedIssues.join(', ')} | Quick: $needQuickSupport'),
                          ),
                        );
                      }
                          : null,
                      child: const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F7FB),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? kBrand : Colors.grey.shade300,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(title),
        checkboxShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        activeColor: kBrand,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}
