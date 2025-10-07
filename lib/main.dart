import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/announcement_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_wrapper.dart';
import 'widgets/forced_update_wrapper.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Try to refresh data when app resumes if we have internet
      final context = navigatorKey.currentContext;
      if (context != null) {
        final attendanceProvider = Provider.of<AttendanceProvider>(
          context,
          listen: false,
        );
        final announcementProvider = Provider.of<AnnouncementProvider>(
          context,
          listen: false,
        );

        // Only attempt refresh if user is logged in and has credentials
        if (attendanceProvider.isLoggedIn &&
            attendanceProvider.collegeId != null) {
          // Use a more graceful refresh that won't clear credentials on network errors
          attendanceProvider.refreshAttendance();
        }
        announcementProvider.refreshIfNeeded();
      }
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final provider = AttendanceProvider();
            // Load any cached data immediately when provider is created
            provider.loadOfflineAttendance();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = AnnouncementProvider();
            return provider;
          },
        ),
      ],
      child: ForcedUpdateWrapper(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Upasthit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF67C9F5),
              brightness: Brightness.light,
              primary: const Color(0xFF67C9F5),
              secondary: const Color(0xFF1B7EE6),
              surface: const Color(0xFFF8F9FA),
              background: const Color(0xFFF5F7FA),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: const Color(0xFF1A1A1A),
              onBackground: const Color(0xFF1A1A1A),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7EE6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2E7D32),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
              bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const MainNavigationWrapper(),
            '/home': (context) => const MainNavigationWrapper(),
          },
        ),
      ),
    );
  }
}
