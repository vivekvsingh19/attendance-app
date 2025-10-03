import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/announcement.dart';
import '../services/sheets_announcement_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;
  static const String _storageKey = 'announcements';

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get the most important/recent announcement for floating banner
  Announcement? get currentAnnouncement {
    if (_announcements.isEmpty) return null;
    
    // First check for important announcements
    final importantOnes = _announcements.where((a) => a.isImportant).toList();
    if (importantOnes.isNotEmpty) {
      return importantOnes.first;
    }
    
    // Otherwise return the most recent one
    return _announcements.first;
  }

  AnnouncementProvider() {
    _loadLocalAnnouncements();
    fetchAnnouncements();
  }

  // Fetch from Google Sheets
  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final announcements = await SheetsAnnouncementService.getAnnouncements();
      _announcements = announcements;
      _lastFetch = DateTime.now();
      _error = null;
      
      // Save to local storage as backup with timestamp
      await _saveLocalAnnouncements();
    } catch (e) {
      _error = 'Failed to load announcements: $e';
      print('Error fetching announcements: $e');
      
      // If online fetch fails, load local data and inform user
      await _loadLocalAnnouncements();
      if (_announcements.isNotEmpty) {
        _error = 'Using cached announcements (offline mode)';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auto refresh if data is old (30 minutes)
  Future<void> refreshIfNeeded() async {
    if (_lastFetch == null || DateTime.now().difference(_lastFetch!).inMinutes > 30) {
      await fetchAnnouncements();
    }
  }

  Future<void> _loadLocalAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final announcementsJson = prefs.getStringList(_storageKey) ?? [];
      
      _announcements = announcementsJson
          .map((jsonString) => Announcement.fromJson(json.decode(jsonString)))
          .toList();
      
      // Sort by creation date (newest first)
      _announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading local announcements: $e');
    }
  }

  Future<void> _saveLocalAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final announcementsJson = _announcements
          .map((announcement) => json.encode(announcement.toJson()))
          .toList();
      
      await prefs.setStringList(_storageKey, announcementsJson);
      // Save timestamp when announcements were last updated from server
      await prefs.setString('announcements_last_update', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving announcements: $e');
    }
  }

  List<Announcement> get importantAnnouncements => 
      _announcements.where((announcement) => announcement.isImportant).toList();

  List<Announcement> get recentAnnouncements => 
      _announcements.take(3).toList();
}
