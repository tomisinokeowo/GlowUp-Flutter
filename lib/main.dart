import 'package:flutter/material.dart';
import 'screens/gender_screen.dart';
import 'navigation/app_navigator.dart';
import 'utils/storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userGender;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkGender();
  }

  Future<void> checkGender() async {
    final gender = await Storage.getString('userGender');
    setState(() {
      userGender = gender;
      isLoading = false;
    });
  }

  void handleGenderSelected(String gender) {
    setState(() {
      userGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFF8F4FF),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'GlowUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFFF8F4FF),
      ),
      home: userGender == null
          ? GenderScreen(onGenderSelected: handleGenderSelected)
          : AppNavigator(userGender: userGender!),
    );
  }
}