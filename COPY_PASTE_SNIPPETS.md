# Copy-Paste Code Snippets for Premium Features

## 🎯 Quick Implementation - Just Copy & Paste!

### 1. Add Imports (Add to top of home_screen.dart and settings_screen.dart)

```dart
import '../widgets/premium_feature_guard.dart';
import '../providers/subscription_provider.dart';
import 'dart:math'; // Only needed for subject card limiting
```

---

## 📍 File: lib/screens/home_screen.dart

### Snippet 1: Protect Critical Subjects (Line ~1318)

**FIND:**
```dart
void _showCriticalSubjects(
  BuildContext context,
  AttendanceProvider provider,
) {
  final threshold = provider.settings.attendanceThreshold;
```

**REPLACE WITH:**
```dart
void _showCriticalSubjects(
  BuildContext context,
  AttendanceProvider provider,
) {
  // Premium check
  final subscription = context.read<SubscriptionProvider>();
  if (!subscription.isPremium) {
    Navigator.pushNamed(context, '/paywall');
    return;
  }

  final threshold = provider.settings.attendanceThreshold;
```

---

### Snippet 2: Protect Safe Bunks (Line ~1356)

**FIND:**
```dart
void _showSafeBunksInfo(BuildContext context, AttendanceProvider provider) {
  final threshold = provider.settings.attendanceThreshold;
```

**REPLACE WITH:**
```dart
void _showSafeBunksInfo(BuildContext context, AttendanceProvider provider) {
  // Premium check
  final subscription = context.read<SubscriptionProvider>();
  if (!subscription.isPremium) {
    Navigator.pushNamed(context, '/paywall');
    return;
  }

  final threshold = provider.settings.attendanceThreshold;
```

---

### Snippet 3: Limit Subject Cards (Line ~1470)

**FIND:**
```dart
// Subjects list
Expanded(
  child: ListView.builder(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: subjects.length,
    itemBuilder: (context, index) {
      final subject = subjects[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: SubjectCard(subject: subject),
      );
    },
  ),
),
```

**REPLACE WITH:**
```dart
// Subjects list
Expanded(
  child: Consumer<SubscriptionProvider>(
    builder: (context, subscription, _) {
      // Calculate how many items to show
      int itemCount = subjects.length;
      if (!subscription.isPremium) {
        // Free users: show 2 subjects + 1 locked card = 3 items
        itemCount = min(3, subjects.length);
      }

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          // Show first 2 cards for free
          if (index < 2) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SubjectCard(subject: subject),
            );
          }

          // Show locked card at position 2 for free users
          if (index == 2 && !subscription.isPremium) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: PremiumFeatureGuard(
                featureName: 'All Subject Details',
                featureDescription: 'Unlock detailed view for all ${subjects.length} subjects',
                child: SizedBox(),
              ),
            );
          }

          // Premium users see all cards
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: SubjectCard(subject: subject),
          );
        },
      );
    },
  ),
),
```

---

### Snippet 4: Add Premium Badge to Critical Subjects Card (Line ~572)

**FIND:**
```dart
Expanded(
  child: _buildStatCard(
    title: 'Critical Subjects',
    value: '$criticalSubjects',
    color: const Color(0xFFEF4444),
    icon: Icons.warning_rounded,
    onTap: () => _showCriticalSubjects(context, provider),
  ),
),
```

**REPLACE WITH:**
```dart
Expanded(
  child: Consumer<SubscriptionProvider>(
    builder: (context, subscription, _) {
      return _buildStatCard(
        title: 'Critical Subjects',
        value: subscription.isPremium ? '$criticalSubjects' : '🔒',
        color: const Color(0xFFEF4444),
        icon: Icons.warning_rounded,
        onTap: () => _showCriticalSubjects(context, provider),
      );
    },
  ),
),
```

---

### Snippet 5: Add Premium Badge to Safe Bunks Card (Line ~580)

**FIND:**
```dart
Expanded(
  child: _buildStatCard(
    title: 'Safe Bunks',
    value: '$safeBunks',
    color: const Color(0xFF10B981),
    icon: Icons.free_breakfast_rounded,
    onTap: () => _showSafeBunksInfo(context, provider),
  ),
),
```

**REPLACE WITH:**
```dart
Expanded(
  child: Consumer<SubscriptionProvider>(
    builder: (context, subscription, _) {
      return _buildStatCard(
        title: 'Safe Bunks',
        value: subscription.isPremium ? '$safeBunks' : '🔒',
        color: const Color(0xFF10B981),
        icon: Icons.free_breakfast_rounded,
        onTap: () => _showSafeBunksInfo(context, provider),
      );
    },
  ),
),
```

---

## 📍 File: lib/screens/settings_screen.dart

### Snippet 6: Protect PDF Generation (Find where Printing.sharePdf is called)

**FIND:**
```dart
await Printing.sharePdf(bytes: pdfBytes, filename: 'attendance_report.pdf');
```

**ADD BEFORE IT:**
```dart
// Premium check for PDF generation
final subscription = context.read<SubscriptionProvider>();
if (!subscription.isPremium) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.star, color: Color(0xFF2E7D32)),
          SizedBox(width: 8),
          Text('Premium Feature'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PDF Report generation is a premium feature.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Upgrade to Upasthit Pro to unlock PDF reports and other advanced features.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Maybe Later'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/paywall');
          },
          icon: Icon(Icons.star, size: 18),
          label: Text('Upgrade Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
  return;
}

// Your existing PDF generation code
await Printing.sharePdf(bytes: pdfBytes, filename: 'attendance_report.pdf');
```

---

## 📍 Protect Date-wise Attendance Navigation

### Find where you navigate to DatewiseAttendanceScreen

**Common locations:**
- In a bottom navigation tab
- In a menu/drawer
- In a button on home screen

**ADD THIS CHECK BEFORE NAVIGATION:**

```dart
// Premium check for date-wise attendance
final subscription = context.read<SubscriptionProvider>();
if (!subscription.isPremium) {
  Navigator.pushNamed(context, '/paywall');
  return;
}

// Your existing navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DatewiseAttendanceScreen()),
);
```

---

## 🎯 Alternative: Protect at Tab Level

If date-wise attendance is in bottom navigation, you can replace the entire tab with a premium guard:

**FIND** (in bottom navigation items):
```dart
BottomNavigationBarItem(
  icon: Icon(Icons.calendar_today),
  label: 'Date-wise',
),
```

**AND IN THE SCREEN SELECTION:**
```dart
case 1: // or whatever index for date-wise
  return DatewiseAttendanceScreen();
```

**REPLACE SCREEN RETURN WITH:**
```dart
case 1:
  return Consumer<SubscriptionProvider>(
    builder: (context, subscription, _) {
      if (subscription.isPremium) {
        return DatewiseAttendanceScreen();
      }
      return Center(
        child: PremiumFeatureGuard(
          featureName: 'Date-wise Attendance',
          featureDescription: 'Track your attendance history day by day',
          child: SizedBox(),
        ),
      );
    },
  );
```

---

## ✅ Quick Checklist

After pasting these snippets:

- [ ] Added imports to home_screen.dart
- [ ] Added imports to settings_screen.dart
- [ ] Protected Critical Subjects method
- [ ] Protected Safe Bunks method
- [ ] Limited subject cards to 2 for free users
- [ ] Added 🔒 to Critical Subjects card
- [ ] Added 🔒 to Safe Bunks card
- [ ] Protected PDF generation
- [ ] Protected date-wise attendance navigation
- [ ] Run `flutter pub get`
- [ ] Test with release build

---

## 🧪 Test Commands

```bash
# Clean build
flutter clean
flutter pub get

# Test with release build
flutter run --release

# Build APK for distribution
flutter build apk --release
```

---

## 💡 Pro Tips

1. **Search shortcut**: Use Ctrl+F (Cmd+F on Mac) to find the exact lines
2. **Multi-cursor**: Use Alt+Click to edit multiple lines at once
3. **Format code**: Use Ctrl+Shift+I after pasting to auto-format
4. **Save all**: Press Ctrl+K S to save all open files

---

## 🎉 You're Done!

After pasting these snippets:
1. Save all files
2. Run `flutter pub get`
3. Test with `flutter run --release`
4. Free users will see locked features
5. Premium users (after subscribing) will see everything!
