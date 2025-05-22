import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' show pi;
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../database_service.dart';
import '../main.dart';
import 'profile_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService databaseService = DatabaseService();
  late ConfettiController _confettiController;
  Timer? _popupTimer;
  bool _showPopup = false;
  int _remainingSeconds = 15;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Add activity listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _startPopupTimer();
    });
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startPopupTimer() {
    _popupTimer?.cancel();
    _remainingSeconds = 15;
    _popupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _showPopup = true;
          }
        });
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _showPopup = false;
      _remainingSeconds = 15;
    });
  }

  Future<void> _logout() async {
    await databaseService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

 @override
  Widget build(BuildContext context) {
    final User? currentUser = databaseService.getCurrentUser();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
          ),
          body: SafeArea(
            child: GestureDetector(
              onTapDown: (_) => _resetTimer(),
              onPanDown: (_) => _resetTimer(),
              onScaleStart: (_) => _resetTimer(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/images/icon2.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome${currentUser?.displayName != null ? ' ${currentUser?.displayName}' : ''}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have successfully logged in',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Session time: $_remainingSeconds seconds',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _resetTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('PROFILE'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
        if (_showPopup)
          AlertDialog(
            title: const Text('Session Timer'),
            content: const Text(
                'Session timer has reached 0 seconds. Click OK to login again.'),
            actions: [
              TextButton(
                onPressed: _logout,
                child: const Text('OK'),
              ),
            ],
          ),
      ],
    );
  }
}
