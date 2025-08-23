import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/attendance_provider.dart';
import '../services/secure_storage_service.dart';
import '../utils/colors.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));
    final provider = context.read<AttendanceProvider>();
    await provider.loadSettings();
    bool isConnected = false;
    try {
      isConnected = await provider.testConnection();
    } catch (_) {
      isConnected = false;
    }

    if (isConnected) {
      final autoLoginSuccess = await provider.checkAndAutoLogin();
      if (autoLoginSuccess) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // Server not reachable, check if user was previously logged in
      final hasOfflineData = await provider.checkOfflineDataAndLogin();
      if (hasOfflineData) {
        // User has offline data and was previously logged in, go to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // No offline data or user was never logged in, go to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              padding: const EdgeInsets.all(32),
              child: Image.asset(
                'assets/images/75+.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 22),
            // App Name
            Text(
              'Upasthit',
              style: GoogleFonts.inknutAntiqua(
                fontSize: 53,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: const Color(0xFF0053A6),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'By Vivek Singh',
              style: GoogleFonts.deliciousHandrawn(
                fontSize: 43,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            // Lottie Loading Animation (larger size)
            SizedBox(
              width: 200,
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Lottie.asset(
                  'assets/icons/Loading.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  }
