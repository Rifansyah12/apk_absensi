class TimeFormatter {
  static String formatMinutesToReadable(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours jam';
      } else {
        return '$hours jam $remainingMinutes menit';
      }
    }
  }

  static String formatMinutesToCompact(int minutes) {
    if (minutes < 60) {
      return '$minutes m';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours j';
      } else {
        return '$hours j $remainingMinutes m';
      }
    }
  }
}