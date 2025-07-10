import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/timetable_service.dart';
import '../utils/colors.dart';

class MyTimetableScreen extends StatefulWidget {
  const MyTimetableScreen({super.key});

  @override
  State<MyTimetableScreen> createState() => _MyTimetableScreenState();
}

class _MyTimetableScreenState extends State<MyTimetableScreen> {
  List<TimetablePhoto> _timetablePhotos = [];
  bool _isLoadingPhotos = false;

  @override
  void initState() {
    super.initState();
    _loadTimetablePhotos();
  }

  Future<void> _loadTimetablePhotos() async {
    setState(() {
      _isLoadingPhotos = true;
    });

    try {
      final photos = await TimetableService.getTimetablePhotos();
      setState(() {
        _timetablePhotos = photos;
        _isLoadingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPhotos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading timetable photos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Timetable Photos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showUploadPhotoDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTimetablePhotos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimetablePhotosSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimetablePhotosSection() {
    if (_isLoadingPhotos) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_timetablePhotos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No timetable photos yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your timetable photos to keep them handy and accessible anytime',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showUploadPhotoDialog(context),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Add Your First Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Timetable Photos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${_timetablePhotos.length} ${_timetablePhotos.length == 1 ? 'photo' : 'photos'}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _timetablePhotos.length,
          itemBuilder: (context, index) {
            return _buildPhotoCard(_timetablePhotos[index]);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoCard(TimetablePhoto photo) {
    return InkWell(
      onTap: () => _showPhotoViewer(photo),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.file(
                  photo.file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.borderLight,
                    child: const Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    photo.formattedDate,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Add Timetable Photo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickTimetablePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickTimetablePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTimetablePhoto(ImageSource source) async {
    final titleController = TextEditingController();
    
    // Show dialog to get title
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'e.g., "Fall 2024 Timetable"',
            labelText: 'Title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(context, titleController.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    
    if (title == null || title.isEmpty) return;
    
    try {
      final filePath = await TimetableService.pickTimetablePhoto(
        source: source,
        title: title,
      );
      
      if (filePath != null) {
        await _loadTimetablePhotos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timetable photo "$title" added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPhotoViewer(TimetablePhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          photo.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      photo.file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 400,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: AppColors.borderLight,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Added: ${photo.formattedDate}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _deletePhoto(photo),
                        icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                        label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhoto(TimetablePhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Are you sure you want to delete "${photo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await TimetableService.deleteTimetablePhoto(photo.title);
        await _loadTimetablePhotos();
        if (mounted) {
          Navigator.pop(context); // Close photo viewer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo "${photo.title}" deleted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
