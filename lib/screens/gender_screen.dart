import 'package:flutter/material.dart';
import '../utils/storage.dart';

class GenderScreen extends StatelessWidget {
  final Function(String) onGenderSelected;

  const GenderScreen({Key? key, required this.onGenderSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '✨ Welcome to GlowUp ✨',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Let\'s personalize your experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'How do you identify?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                _buildGenderButton('Female', const Color(0xFF8B5CF6)),
                const SizedBox(height: 10),
                _buildGenderButton('Male', const Color(0xFF60A5FA)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await Storage.setString('userGender', gender.toLowerCase());
          onGenderSelected(gender.toLowerCase());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          gender,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}