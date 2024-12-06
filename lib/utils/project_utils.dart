import 'package:flutter/material.dart';

class ProjectUtils {
  static List<Widget> buildDetails(Map<String, dynamic> project) {
    final details = {
      'Project Name': project['projectName']?.toString() ?? 'N/A',
      'Designation': project['designation']?.toString() ?? 'N/A',
      'Start Date': project['startDate']?.toString() ?? 'N/A',
      'End Date': project['endDate']?.toString() ?? 'N/A',
      'Days': _calculateDays(
        project['startDate']?.toString(),
        project['endDate']?.toString(),
      ),
      'Project Resource Status':
          project['projectResourceStatusValue']?.toString() ?? 'N/A',
      'Project Allocation': project['projectAllocation']?.toString() ?? 'N/A',
      'Billable Allocation': project['billableAllocation']?.toString() ?? 'N/A',
      'Reporting To': project['currentReportingHead']?.toString() ?? 'N/A',
      'Comments': project['notes']?.toString() ?? 'N/A',
    };

    return details.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold, 
                color: Colors.black87,
              ),
            ),
            Text(
              entry.value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54, 
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Helper method to calculate days between start and end date
  static String _calculateDays(String? startDate, String? endDate) {
    if (startDate == null || startDate.isEmpty) return 'Start Date Missing';
    try {
      final start = DateTime.parse(startDate);
      final end = (endDate != null && endDate.isNotEmpty)
          ? DateTime.parse(endDate)
          : DateTime.now();
      final difference = end.difference(start).inDays;
      return '$difference days';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
