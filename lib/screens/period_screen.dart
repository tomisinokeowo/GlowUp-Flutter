import 'package:flutter/material.dart';
import '../utils/storage.dart';

class PeriodScreen extends StatefulWidget {
  const PeriodScreen({Key? key}) : super(key: key);

  @override
  State<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends State<PeriodScreen> {
  String lastPeriod = '';
  String cycleLength = '28';
  bool saved = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final savedDate = await Storage.getString('lastPeriod');
    final savedCycle = await Storage.getString('cycleLength');
    setState(() {
      if (savedDate != null) lastPeriod = savedDate;
      if (savedCycle != null) cycleLength = savedCycle;
    });
  }

  Future<void> saveData() async {
    await Storage.setString('lastPeriod', lastPeriod);
    await Storage.setString('cycleLength', cycleLength);
    setState(() {
      saved = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        saved = false;
      });
    });
  }

  String calculateNextPeriod() {
    if (lastPeriod.isEmpty) return 'Enter last period date';
    try {
      final last = DateTime.parse(lastPeriod);
      final cycle = int.tryParse(cycleLength) ?? 28;
      final next = last.add(Duration(days: cycle));
      return '${next.day}/${next.month}/${next.year}';
    } catch (e) {
      return 'Invalid date format';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌸 Period Tracker',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 20),
              
              // Input card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Last Period Start Date:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => lastPeriod = value,
                      controller: TextEditingController(text: lastPeriod),
                    ),
                    const SizedBox(height: 16),
                    const Text('Cycle Length (days):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '28',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => cycleLength = value,
                      controller: TextEditingController(text: cycleLength),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('Save'),
                    ),
                    if (saved) ...[
                      const SizedBox(height: 10),
                      const Text('Saved! ✓', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Prediction card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Next Period Predicted:', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Text(
                      calculateNextPeriod(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEC4899)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}