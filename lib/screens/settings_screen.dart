import 'package:flutter/material.dart';
import '../utils/storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all your saved moods, journal entries, and other data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Storage.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared. Restart app.')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                '⚙️ Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 20),
              
              // Privacy card
              _buildCard(
                title: 'Privacy',
                child: const Text(
                  'All data is stored locally on your device only. No data is sent to any server or shared with third parties.',
                  style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
                ),
              ),
              const SizedBox(height: 15),
              
              // Data Management card
              _buildCard(
                title: 'Data Management',
                child: ElevatedButton(
                  onPressed: () => _clearAllData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Clear All Data'),
                ),
              ),
              const SizedBox(height: 15),
              
              // About card
              _buildCard(
                title: 'About',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GlowUp v1.0', style: TextStyle(color: Color(0xFF9CA3AF))),
                    SizedBox(height: 5),
                    Text('Built for educational comparison', style: TextStyle(color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}