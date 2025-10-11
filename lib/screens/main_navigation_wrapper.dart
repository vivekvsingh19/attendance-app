import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:upasthit/screens/bunk_calendar_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'timetable_screen.dart';
import 'datewise_attendance_screen.dart';
import '../providers/subscription_provider.dart';
import '../widgets/premium_feature_guard.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  List<Widget> _getScreens(bool isPremium) {
    return [
      const HomeScreen(),
      const TimetableScreen(),
      isPremium
          ? const DatewiseAttendanceScreen()
          : Center(
            child: PremiumFeatureGuard(
              featureName: 'Date-wise Attendance',
              featureDescription: 'Track your attendance history day by day',
              child: SizedBox(),
            ),
          ),
      isPremium
          ? const BunkCalendarScreen()
          : Center(
            child: PremiumFeatureGuard(
              featureName: 'Bunk Calendar',
              featureDescription: 'Smart bunk calculator and predictor',
              child: SizedBox(),
            ),
          ),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, _) {
        final screens = _getScreens(subscription.isPremium);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF1B7EE6).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Iconsax.home_24,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Iconsax.calendar,
                      label: 'Datewise',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Iconsax.clock,
                      label: 'Timetable',
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Iconsax.clock_1,
                      label: 'Bunks',
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Iconsax.setting_24,
                      label: 'Settings',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.2 : 1.0,
                child: Icon(
                  icon,
                  color:
                      isSelected
                          ? const Color(0xFF1B7EE6)
                          : const Color(0xFF6B7280),
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.6,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected
                            ? const Color(0xFF1B7EE6)
                            : const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
