import 'package:flutter/material.dart';
import '../utils/storage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> entries = [];
  String newEntry = '';

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final saved = await Storage.getString('journalEntries');
    if (saved != null) {
      setState(() {
        entries = List<Map<String, dynamic>>.from(jsonDecode(saved));
      });
    }
  }

  Future<void> saveEntry() async {
    if (newEntry.trim().isEmpty) return;
    
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'text': newEntry,
      'date': DateFormat('MMM d, yyyy').format(DateTime.now()),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final updated = [entry, ...entries];
    await Storage.setString('journalEntries', jsonEncode(updated));
    
    setState(() {
      entries = updated;
      newEntry = '';
    });
  }

  Future<void> deleteEntry(int id) async {
    final updated = entries.where((e) => e['id'] != id).toList();
    await Storage.setString('journalEntries', jsonEncode(updated));
    setState(() {
      entries = updated;
    });
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
                '📝 Journal',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 20),
              
              // Input card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'How was your day? Write your thoughts here...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => newEntry = value,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: saveEntry,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                        child: const Text('Save Entry'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Entries list
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text(
                          'No entries yet. Start writing!',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry['date'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => deleteEntry(entry['id']),
                                      child: const Text('🗑️', style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry['text'],
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                                ),
                              ],
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