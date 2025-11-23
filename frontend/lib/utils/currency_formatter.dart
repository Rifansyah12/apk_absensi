class CurrencyFormatter {
  static String formatRupiah(double amount) {
    // Handle nilai negatif
    bool isNegative = amount < 0;
    String amountString = amount.abs().toStringAsFixed(0);
    
    // Format angka dengan separator ribuan
    String formatted = '';
    int count = 0;
    
    for (int i = amountString.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = amountString[i] + formatted;
      count++;
    }
    
    // Kembalikan dengan format Rp yang benar
    return isNegative ? '-Rp $formatted' : 'Rp $formatted';
  }

  static String formatCompactRupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    } else {
      return formatRupiah(amount);
    }
  }
}