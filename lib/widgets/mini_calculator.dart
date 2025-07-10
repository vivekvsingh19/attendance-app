import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MiniCalculator extends StatefulWidget {
  const MiniCalculator({super.key});

  @override
  State<MiniCalculator> createState() => _MiniCalculatorState();
}

class _MiniCalculatorState extends State<MiniCalculator> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _attendedController = TextEditingController();
  
  int _classesNeeded = 0;
  int _safeBunks = 0;
  bool _isCalculated = false;

  @override
  void dispose() {
    _targetController.dispose();
    _totalController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  void _calculateAttendance() {
    final target = double.tryParse(_targetController.text) ?? 75.0;
    final total = int.tryParse(_totalController.text) ?? 0;
    final attended = int.tryParse(_attendedController.text) ?? 0;

    if (total == 0) {
      setState(() {
        _classesNeeded = 0;
        _safeBunks = 0;
        _isCalculated = false;
      });
      return;
    }

    final currentPercentage = (attended / total) * 100;
    
    if (currentPercentage < target) {
      // Calculate classes needed to reach target
      _classesNeeded = ((target * total - attended * 100) / (100 - target)).ceil();
      _safeBunks = 0;
    } else {
      // Calculate safe bunks
      _classesNeeded = 0;
      _safeBunks = ((attended * 100 - target * total) / target).floor();
    }

    setState(() {
      _isCalculated = true;
    });
  }

  void _clearCalculation() {
    setState(() {
      _targetController.clear();
      _totalController.clear();
      _attendedController.clear();
      _classesNeeded = 0;
      _safeBunks = 0;
      _isCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Attendance Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Input fields
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _targetController,
                  label: 'Target %',
                  hint: '75',
                  icon: Icons.flag_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _totalController,
                  label: 'Total Classes',
                  hint: '50',
                  icon: Icons.class_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _attendedController,
                  label: 'Attended',
                  hint: '35',
                  icon: Icons.check_circle_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _calculateAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calculate_rounded, size: 18),
                  label: const Text(
                    'Calculate',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _clearCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.borderLight,
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.clear_rounded, size: 18),
              ),
            ],
          ),
          
          // Results
          if (_isCalculated) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (_classesNeeded > 0) ...[
                    Expanded(
                      child: _buildResultCard(
                        'Classes Needed',
                        _classesNeeded.toString(),
                        Icons.schedule_rounded,
                        AppColors.error,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: _buildResultCard(
                        'Safe Bunks',
                        _safeBunks.toString(),
                        Icons.free_breakfast_rounded,
                        AppColors.success,
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResultCard(
                      'Current %',
                      '${((int.tryParse(_attendedController.text) ?? 0) / (int.tryParse(_totalController.text) ?? 1) * 100).toStringAsFixed(1)}%',
                      Icons.trending_up_rounded,
                      AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
