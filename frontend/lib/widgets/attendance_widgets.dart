import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

class AttendanceWidgets {
  // Widget untuk menampilkan info row dengan icon
  static Widget buildInfoRowWithIcon({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    double iconSize = 16,
    double fontSize = 12,
  }) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  // Widget untuk menampilkan keterlambatan dengan format yang readable
  static Widget buildLateMinutesInfo({
    required int? lateMinutes,
    bool useCompactFormat = false,
    double iconSize = 16,
    double fontSize = 12,
  }) {
    if (lateMinutes == null || lateMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final formattedTime = useCompactFormat
        ? TimeFormatter.formatMinutesToCompact(lateMinutes)
        : TimeFormatter.formatMinutesToReadable(lateMinutes);

    return buildInfoRowWithIcon(
      icon: Icons.schedule,
      label: 'Terlambat:',
      value: formattedTime,
      color: Colors.orange,
      iconSize: iconSize,
      fontSize: fontSize,
    );
  }

  // Widget untuk badge keterlambatan (seperti di AbsensiPage)
  static Widget buildLateBadge({
    required int? lateMinutes,
    bool useCompactFormat = true,
  }) {
    if (lateMinutes == null || lateMinutes <= 0) {
      return const SizedBox.shrink();
    }

    final formattedTime = useCompactFormat
        ? TimeFormatter.formatMinutesToCompact(lateMinutes)
        : TimeFormatter.formatMinutesToReadable(lateMinutes);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(
        '$formattedTime telat',
        style: TextStyle(
          color: Colors.orange[800],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget untuk info row sederhana (seperti di AbsensiDetailPage)
  static Widget buildSimpleInfoRow({
    required String label,
    required String value,
    bool isImportant = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? (isImportant ? Colors.blueAccent : Colors.black87),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk info row dengan keterlambatan yang diformat
  static Widget buildLateMinutesRow({
    required int? lateMinutes,
    bool isImportant = false,
  }) {
    if (lateMinutes == null || lateMinutes <= 0) {
      return const SizedBox.shrink();
    }

    return buildSimpleInfoRow(
      label: "Keterlambatan:",
      value: TimeFormatter.formatMinutesToReadable(lateMinutes),
      isImportant: isImportant,
      valueColor: Colors.orange,
    );
  }
}