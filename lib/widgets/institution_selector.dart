import 'package:flutter/material.dart';

class InstitutionSelector extends StatelessWidget {
  final String selectedInstitution;
  final Function(String) onChanged;

  const InstitutionSelector({
    super.key,
    required this.selectedInstitution,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Institution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.school, color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'LNCT College',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'portal.lnct.ac.in',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: 'college',
                  groupValue: selectedInstitution,
                  onChanged: (value) => onChanged(value!),
                  activeColor: const Color(0xFF2E7D32),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.account_balance, color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'LNCT University',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'accsoft2.lnctu.ac.in',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: 'university',
                  groupValue: selectedInstitution,
                  onChanged: (value) => onChanged(value!),
                  activeColor: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
