import 'package:flutter/material.dart';
import '../utils/storage.dart';
import 'dart:convert';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Map<String, dynamic>> routines = [
    {'id': 1, 'title': 'Morning Meditation', 'completed': false, 'streak': 5},
    {'id': 2, 'title': 'Drink 8 Glasses of Water', 'completed': false, 'streak': 3},
    {'id': 3, 'title': 'Evening Walk', 'completed': false, 'streak': 7},
    {'id': 4, 'title': 'Read 30 Minutes', 'completed': false, 'streak': 2},
  ];
  String newRoutine = '';

  @override
  void initState() {
    super.initState();
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    final saved = await Storage.getString('routines');
    if (saved != null) {
      setState(() {
        routines = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  Future<void> toggleRoutine(int id) async {
    final updated = routines.map((r) {
      if (r['id'] == id) {
        return {
          ...r,
          'completed': !r['completed'],
          'streak': r['completed'] ? r['streak'] - 1 : r['streak'] + 1,
        };
      }
      return r;
    }).toList();
    
    await Storage.setString('routines', jsonEncode(updated));
    setState(() {
      routines = updated;
    });
  }

  Future<void> addRoutine() async {
    if (newRoutine.trim().isEmpty) return;
    
    final routine = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': newRoutine,
      'completed': false,
      'streak': 0,
    };
    
    final updated = [...routines, routine];
    await Storage.setString('routines', jsonEncode(updated));
    
    setState(() {
      routines = updated;
      newRoutine = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = routines.where((r) => r['completed'] == true).length;
    final progress = routines.isNotEmpty ? (completedCount / routines.length) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🌟 Routines',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 20),
              
              // Progress card
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
                    const Text('Daily Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${progress.round()}%', style: const TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              // Add routine input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Add new routine...',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => newRoutine = value,
                        onSubmitted: (_) => addRoutine(),
                      ),
                    ),
                    IconButton(
                      onPressed: addRoutine,
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              // Routines list
              Expanded(
                child: ListView.builder(
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: routine['completed'] ? const Color(0xFFF3F4F6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => toggleRoutine(routine['id']),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                                color: routine['completed'] ? const Color(0xFF8B5CF6) : Colors.transparent,
                              ),
                              child: routine['completed']
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    routine['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      decoration: routine['completed'] ? TextDecoration.lineThrough : null,
                                      color: routine['completed'] ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '🔥 ${routine['streak']} day streak',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}