import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableService {
  static const String _timetablePhotosKey = 'timetable_photos';
  static const String _timetablePhotosDir = 'timetable_photos';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final timetableDir = Directory('${directory.path}/$_timetablePhotosDir');
    
    if (!await timetableDir.exists()) {
      await timetableDir.create(recursive: true);
    }
    
    return timetableDir.path;
  }

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.status;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  static Future<String?> pickTimetablePhoto({
    required ImageSource source,
    required String title,
  }) async {
    try {
      // Request permissions
      if (!await _requestPermissions()) {
        throw Exception('Permission denied to access photos');
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title.replaceAll(' ', '_').toLowerCase()}_$timestamp.jpg';
      
      // Save to app directory
      final String path = await _localPath;
      final File localFile = File('$path/$fileName');
      await localFile.writeAsBytes(await photo.readAsBytes());

      // Store reference in SharedPreferences
      await _saveTimetablePhotoReference(title, localFile.path);

      return localFile.path;
    } catch (e) {
      debugPrint('Error picking timetable photo: $e');
      return null;
    }
  }

  static Future<void> _saveTimetablePhotoReference(String title, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> photos = prefs.getStringList(_timetablePhotosKey) ?? [];
    
    // Create a reference string: "title|filePath"
    final reference = '$title|$filePath';
    
    // Remove existing reference for this title if it exists
    photos.removeWhere((photo) => photo.startsWith('$title|'));
    
    // Add new reference
    photos.add(reference);
    
    await prefs.setStringList(_timetablePhotosKey, photos);
  }

  static Future<List<TimetablePhoto>> getTimetablePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> photos = prefs.getStringList(_timetablePhotosKey) ?? [];
    
    List<TimetablePhoto> timetablePhotos = [];
    
    for (String photoRef in photos) {
      final parts = photoRef.split('|');
      if (parts.length == 2) {
        final title = parts[0];
        final filePath = parts[1];
        
        // Check if file still exists
        final file = File(filePath);
        if (await file.exists()) {
          timetablePhotos.add(TimetablePhoto(
            title: title,
            filePath: filePath,
            dateAdded: file.lastModifiedSync(),
          ));
        }
      }
    }
    
    // Sort by date added (newest first)
    timetablePhotos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    return timetablePhotos;
  }

  static Future<bool> deleteTimetablePhoto(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> photos = prefs.getStringList(_timetablePhotosKey) ?? [];
    
    // Find and remove the reference
    final photoRef = photos.firstWhere(
      (photo) => photo.startsWith('$title|'),
      orElse: () => '',
    );
    
    if (photoRef.isEmpty) return false;
    
    // Remove file
    final filePath = photoRef.split('|')[1];
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Remove reference from SharedPreferences
    photos.removeWhere((photo) => photo.startsWith('$title|'));
    await prefs.setStringList(_timetablePhotosKey, photos);
    
    return true;
  }

  static Future<void> clearAllTimetablePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> photos = prefs.getStringList(_timetablePhotosKey) ?? [];
    
    // Delete all files
    for (String photoRef in photos) {
      final parts = photoRef.split('|');
      if (parts.length == 2) {
        final file = File(parts[1]);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    
    // Clear references
    await prefs.remove(_timetablePhotosKey);
  }
}

class TimetablePhoto {
  final String title;
  final String filePath;
  final DateTime dateAdded;

  TimetablePhoto({
    required this.title,
    required this.filePath,
    required this.dateAdded,
  });

  File get file => File(filePath);
  
  String get formattedDate {
    return '${dateAdded.day}/${dateAdded.month}/${dateAdded.year}';
  }
}
