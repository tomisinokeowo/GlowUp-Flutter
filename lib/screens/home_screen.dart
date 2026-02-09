import 'package:flutter/material.dart';
import '../utils/storage.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? todayMood;
  List<Map<String, dynamic>> moodHistory = [];
  int waterCount = 0;
  int steps = 0;
  String stepInput = '';
  List<Map<String, dynamic>> checklist = [
    {'id': 1, 'text': 'Morning stretch', 'completed': false},
    {'id': 2, 'text': 'Take vitamins', 'completed': false},
    {'id': 3, 'text': 'No phone before bed', 'completed': false},
  ];
  String newChecklistItem = '';

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'label': 'Great', 'color': '#10B981'},
    {'emoji': '😐', 'label': 'Okay', 'color': '#F59E0B'},
    {'emoji': '😔', 'label': 'Low', 'color': '#6B7280'},
    {'emoji': '😰', 'label': 'Anxious', 'color': '#8B5CF6'},
    {'emoji': '😴', 'label': 'Tired', 'color': '#3B82F6'},
  ];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadTodayMood(),
      loadMoodHistory(),
      loadWaterCount(),
      loadSteps(),
      loadChecklist(),
    ]);
    setState(() {});
  }

  Future<void> loadTodayMood() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final saved = await Storage.getString('mood_$today');
    if (saved != null) {
      setState(() {
        todayMood = jsonDecode(saved);
      });
    }
  }

  Future<void> loadMoodHistory() async {
    List<Map<String, dynamic>> history = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final saved = await Storage.getString('mood_$dateStr');
      if (saved != null) {
        history.add({
          'date': dateStr,
          'mood': jsonDecode(saved),
          'dayName': i == 0 ? 'Today' : _getWeekday(date),
        });
      }
    }
    setState(() {
      moodHistory = history;
    });
  }

  String _getWeekday(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  Future<void> loadWaterCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final saved = await Storage.getInt('water_$today');
    if (saved != null) {
      setState(() {
        waterCount = saved;
      });
    }
  }

  Future<void> loadSteps() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final saved = await Storage.getInt('steps_$today');
    if (saved != null) {
      setState(() {
        steps = saved;
      });
    }
  }

  Future<void> loadChecklist() async {
    final saved = await Storage.getString('checklist');
    if (saved != null) {
      setState(() {
        checklist = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  Future<void> selectMood(Map<String, dynamic> mood) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await Storage.setString('mood_$today', jsonEncode(mood));
    setState(() {
      todayMood = mood;
    });
    loadMoodHistory();
    Navigator.pop(context);
  }

  Future<void> addWater() async {
    final newCount = waterCount + 1;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await Storage.setInt('water_$today', newCount);
    setState(() {
      waterCount = newCount;
    });
  }

  Future<void> addSteps() async {
    final newSteps = int.tryParse(stepInput) ?? 0;
    final total = steps + newSteps;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await Storage.setInt('steps_$today', total);
    setState(() {
      steps = total;
      stepInput = '';
    });
  }

  Future<void> toggleChecklistItem(int id) async {
    final updated = checklist.map((item) {
      if (item['id'] == id) {
        return {...item, 'completed': !item['completed']};
      }
      return item;
    }).toList();
    await Storage.setString('checklist', jsonEncode(updated));
    setState(() {
      checklist = updated;
    });
  }

  Future<void> addChecklistItem() async {
    if (newChecklistItem.trim().isEmpty) return;
    final item = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'text': newChecklistItem,
      'completed': false,
    };
    final updated = [...checklist, item];
    await Storage.setString('checklist', jsonEncode(updated));
    setState(() {
      checklist = updated;
      newChecklistItem = '';
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void showMoodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: moods.map((mood) => GestureDetector(
                onTap: () => selectMood(mood),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(int.parse(mood['color'].substring(1), radix: 16) + 0x20000000),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
                      Text(mood['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = checklist.where((item) => item['completed'] == true).length;
    final checklistProgress = checklist.isNotEmpty ? (completedCount / checklist.length) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '✨ GlowUp ✨',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your Self-Care Journey',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Today's Mood
              if (todayMood != null)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(int.parse(todayMood!['color'].substring(1), radix: 16) + 0x20000000),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(todayMood!['emoji'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Text('Today: ${todayMood!['label']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 15),

              // Daily Check-in Card
              _buildCard(
                title: 'Daily Check-in',
                subtitle: 'How are you feeling today?',
                buttonText: todayMood != null ? 'Update Mood' : 'Start',
                onPressed: showMoodSelector,
              ),
              const SizedBox(height: 15),

              // Water Tracker
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        const Text('Water Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$waterCount/8 glasses', style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: List.generate(8, (index) => IconButton(
                        onPressed: addWater,
                        icon: Icon(
                          Icons.water_drop,
                          color: index < waterCount ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                        ),
                      )),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: addWater,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                      child: const Text('+ Add Glass'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Steps Tracker
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        const Text('Steps Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(steps.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Add steps...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => stepInput = value,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: addSteps,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Daily Checklist
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('📋 Daily Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        Text('${checklistProgress.round()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: checklistProgress / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                    ),
                    const SizedBox(height: 15),
                    ...checklist.map((item) => CheckboxListTile(
                      value: item['completed'],
                      onChanged: (_) => toggleChecklistItem(item['id']),
                      title: Text(
                        item['text'],
                        style: TextStyle(
                          decoration: item['completed'] ? TextDecoration.lineThrough : null,
                          color: item['completed'] ? Colors.grey : Colors.black,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Add new item...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => newChecklistItem = value,
                            onSubmitted: (_) => addChecklistItem(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: addChecklistItem,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Mood History
              if (moodHistory.isNotEmpty)
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 Last 7 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: moodHistory.map((item) => Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(item['mood']['color'].substring(1), radix: 16) + 0x30000000),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(child: Text(item['mood']['emoji'], style: const TextStyle(fontSize: 24))),
                                ),
                                const SizedBox(height: 5),
                                Text(item['dayName'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),

              // Daily Tip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(left: BorderSide(color: Color(0xFF10B981), width: 4)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Daily Tip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                    SizedBox(height: 8),
                    Text('Take 3 deep breaths when you feel overwhelmed. You\'ve got this!', style: TextStyle(color: Color(0xFF047857))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({String? title, String? subtitle, String? buttonText, VoidCallback? onPressed, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child ?? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
          ],
          if (buttonText != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }
}