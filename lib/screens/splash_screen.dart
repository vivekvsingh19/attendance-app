import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/attendance_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/secure_storage_service.dart';
import '../utils/colors.dart';

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
    // Keep splash minimal and fast. Do only quick local work and navigate.
    await Future.delayed(const Duration(milliseconds: 600));

    // Capture navigator to avoid using BuildContext after async gaps
    final navigator = Navigator.of(context);

    final provider = context.read<AttendanceProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();
    
    // Load lightweight settings so UI can read preferences immediately
    await provider.loadSettings();

    // Decide route based on cached login flag. Avoid blocking network calls here.
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (wasLoggedIn) {
        // Initialize RevenueCat with user BEFORE navigating
        debugPrint('👤 User was previously logged in, initializing RevenueCat...');
        try {
          final creds = await SecureStorageService.getCredentials();
          final username = creds['username'];
          
          if (username != null && username.isNotEmpty) {
            debugPrint('🔗 Linking user to RevenueCat: $username');
            await subscriptionProvider.initialize(username);
            debugPrint('✅ RevenueCat initialized. Premium: ${subscriptionProvider.isPremium}');
          }
        } catch (e) {
          debugPrint('⚠️  Error initializing RevenueCat: $e');
        }
        
        // Navigate to home quickly. Provider will populate cached attendance (loaded earlier
        // from main's provider creation) and then attempt network refresh in background.
        navigator.pushReplacementNamed('/home');

        // Run background refresh/auto-login without blocking navigation.
        // These calls update the provider when data arrives and will notify listeners.
        // We deliberately don't await them to keep startup snappy.
        provider.checkOfflineDataAndLogin();
        provider.checkAndAutoLogin().then((success) {
          // No further navigation here; HomeScreen listens to provider changes.
        }).catchError((_) {
          // Ignore background errors; HomeScreen will show cached data or error.
        });
      } else {
        // Not previously logged in — go to login immediately.
        navigator.pushReplacementNamed('/login');
      }
    } catch (e) {
      // If anything goes wrong reading prefs, fallback to login after quick navigation.
      navigator.pushReplacementNamed('/login');
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
