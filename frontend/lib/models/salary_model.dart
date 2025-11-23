class Salary {
  final int id;
  final int userId;
  final int month;
  final int year;
  final double baseSalary;
  final double overtimeSalary;
  final double deduction;
  final double totalSalary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Salary({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.overtimeSalary,
    required this.deduction,
    required this.totalSalary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      userId: json['userId'],
      month: json['month'],
      year: json['year'],
      baseSalary: (json['baseSalary'] is int) 
          ? (json['baseSalary'] as int).toDouble() 
          : json['baseSalary'],
      overtimeSalary: (json['overtimeSalary'] is int)
          ? (json['overtimeSalary'] as int).toDouble()
          : json['overtimeSalary'],
      deduction: (json['deduction'] is int)
          ? (json['deduction'] as int).toDouble()
          : json['deduction'],
      totalSalary: (json['totalSalary'] is int)
          ? (json['totalSalary'] as int).toDouble()
          : json['totalSalary'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Get month name in Indonesian
  String get monthName {
    switch (month) {
      case 1: return 'Januari';
      case 2: return 'Februari';
      case 3: return 'Maret';
      case 4: return 'April';
      case 5: return 'Mei';
      case 6: return 'Juni';
      case 7: return 'Juli';
      case 8: return 'Agustus';
      case 9: return 'September';
      case 10: return 'Oktober';
      case 11: return 'November';
      case 12: return 'Desember';
      default: return 'Bulan $month';
    }
  }

  // Get period string
  String get period => '$monthName $year';

  // Check if this is the current period
  bool get isCurrentPeriod {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }
}

class SalarySummary {
  final double totalBaseSalary;
  final double totalOvertime;
  final double totalDeductions;
  final double netSalary;

  SalarySummary({
    required this.totalBaseSalary,
    required this.totalOvertime,
    required this.totalDeductions,
    required this.netSalary,
  });
}