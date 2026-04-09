import 'package:flutter/services.dart';

/// Number Format Utils for Indonesian Format
///
/// Rules:
/// - Integer: dot (.) thousands separator (1.500, 10.000, 1.000.000)
/// - Decimal: dot thousands + comma (,) decimal (1.234,56)
/// - Compact (< 10K): Full number (1.500, 9.999)
/// - Compact (≥ 10K, < 1M): "X Ribu" with comma decimal (10 Ribu, 95,8 Ribu)
/// - Compact (≥ 1M): "X Jt" with comma decimal (1,5 Jt, 2,3 Jt)
/// - Percentage: comma decimal, 2 places (12,34%)
class NumberFormatUtils {
  /// Format integer with Indonesian thousands separator (dot)
  /// Examples: 1500 → 1.500, 1000000 → 1.000.000
  static String formatInteger(int number) {
    if (number == 0) return '0';

    final String numStr = number.abs().toString();
    final StringBuffer result = StringBuffer();

    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result.write('.');
      }
      result.write(numStr[i]);
      count++;
    }

    final String formatted = result.toString().split('').reversed.join('');
    return number < 0 ? '-$formatted' : formatted;
  }

  /// Format double with Indonesian notation
  /// Examples: 1234.56 → 1.234,56, 1000000.5 → 1.000.000,5
  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    if (number.isNaN || number.isInfinite) return 'N/A';

    // Split into integer and decimal parts
    final bool isNegative = number < 0;
    final double absNumber = number.abs();
    final int integerPart = absNumber.truncate();
    final double decimalPart = absNumber - integerPart;

    // Format integer part with thousands separator
    final String formattedInteger = formatInteger(integerPart);

    // Format decimal part
    if (decimalPlaces == 0) {
      return isNegative ? '-$formattedInteger' : formattedInteger;
    }

    final double roundedDecimal =
        (decimalPart * _pow10(decimalPlaces)).round() / _pow10(decimalPlaces);
    final String decimalStr =
        roundedDecimal.toStringAsFixed(decimalPlaces).substring(2);

    // Remove trailing zeros
    final String trimmedDecimal = decimalStr.replaceAll(RegExp(r'0+$'), '');

    if (trimmedDecimal.isEmpty) {
      return isNegative ? '-$formattedInteger' : formattedInteger;
    }

    return isNegative
        ? '-$formattedInteger,$trimmedDecimal'
        : '$formattedInteger,$trimmedDecimal';
  }

  /// Format number in compact Indonesian notation
  /// Examples:
  /// - 1500 → 1.500
  /// - 10000 → 10 Ribu
  /// - 95800 → 95,8 Ribu
  /// - 1500000 → 1,5 Jt
  static String formatCompact(num number) {
    if (number == 0) return '0';
    if (number.isNaN || number.isInfinite) return 'N/A';

    final bool isNegative = number < 0;
    final double absNumber = number.abs().toDouble();

    String result;

    if (absNumber < 10000) {
      // Full number format
      result = formatInteger(absNumber.toInt());
    } else if (absNumber < 1000000) {
      // Ribu format
      final double ribuValue = absNumber / 1000;
      result = '${formatDecimal(ribuValue, decimalPlaces: 1)} Ribu';
    } else {
      // Juta format
      final double jutaValue = absNumber / 1000000;
      result = '${formatDecimal(jutaValue, decimalPlaces: 1)} Jt';
    }

    return isNegative ? '-$result' : result;
  }

  /// Format percentage with Indonesian decimal separator
  /// Examples: 12.34 → 12,34%
  static String formatPercentage(double value) {
    if (value.isNaN || value.isInfinite) return 'N/A';
    return '${formatDecimal(value, decimalPlaces: 2)}%';
  }

  /// Parse Indonesian formatted number string back to double
  /// Handles: 1.234,56 → 1234.56, 10 Ribu → 10000, 1,5 Jt → 1500000
  static double? parseIndonesianNumber(String text) {
    if (text.isEmpty) return null;

    String cleaned = text.trim();

    // Handle compact formats
    if (cleaned.toLowerCase().contains('ribu')) {
      cleaned = cleaned.toLowerCase().replaceAll('ribu', '').trim();
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      final double? value = double.tryParse(cleaned);
      return value != null ? value * 1000 : null;
    }

    if (cleaned.toLowerCase().contains('jt')) {
      cleaned = cleaned.toLowerCase().replaceAll('jt', '').trim();
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      final double? value = double.tryParse(cleaned);
      return value != null ? value * 1000000 : null;
    }

    // Handle regular format: 1.234,56
    cleaned = cleaned.replaceAll('.', ''); // Remove thousands separator
    cleaned = cleaned.replaceAll(',', '.'); // Convert decimal separator

    return double.tryParse(cleaned);
  }

  /// Parse Indonesian formatted integer
  static int? parseIndonesianInteger(String text) {
    final double? value = parseIndonesianNumber(text);
    return value != null ? value.toInt() : null;
  }

  /// Helper method to format value for display
  static String formatValue(dynamic value,
      {bool isCompact = false, bool isPercentage = false, int? decimalPlaces}) {
    if (value == null) return 'N/A';

    if (isPercentage) {
      if (value is num) {
        return formatPercentage(value.toDouble());
      }
      return '$value%';
    }

    if (value is int) {
      return isCompact ? formatCompact(value) : formatInteger(value);
    }

    if (value is double) {
      if (isCompact) {
        return formatCompact(value);
      }
      return formatDecimal(value, decimalPlaces: decimalPlaces ?? 2);
    }

    return value.toString();
  }

  /// Helper to calculate power of 10
  static int _pow10(int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}

/// Input Formatter for Indonesian number format
/// Auto-adds thousands separator dots as user types
class IndonesianNumberInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final int decimalPlaces;

  IndonesianNumberInputFormatter({
    this.allowDecimal = false,
    this.decimalPlaces = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;

    // Check if it's a negative number
    final bool isNegative = text.startsWith('-');
    if (isNegative) {
      text = text.substring(1);
    }

    // Split into integer and decimal parts
    List<String> parts = text.split(',');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Clean integer part (remove all non-digits)
    integerPart = integerPart.replaceAll(RegExp(r'[^0-9]'), '');

    // Remove leading zeros (except if it's just "0")
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
    }

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    // Format integer part with thousands separator
    final StringBuffer formattedInteger = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger.write('.');
      }
      formattedInteger.write(integerPart[i]);
      count++;
    }

    String result = formattedInteger.toString().split('').reversed.join('');

    // Add decimal part if allowed and present
    if (allowDecimal && decimalPart != null) {
      // Limit decimal places
      if (decimalPart.length > decimalPlaces) {
        decimalPart = decimalPart.substring(0, decimalPlaces);
      }
      // Clean decimal part
      decimalPart = decimalPart.replaceAll(RegExp(r'[^0-9]'), '');
      if (decimalPart.isNotEmpty) {
        result = '$result,$decimalPart';
      }
    }

    // Add negative sign if needed
    if (isNegative) {
      result = '-$result';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Input Formatter for percentage values
class IndonesianPercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll('%', '').trim();

    // Check if it's a negative number
    final bool isNegative = text.startsWith('-');
    if (isNegative) {
      text = text.substring(1);
    }

    // Split into integer and decimal parts
    List<String> parts = text.split(',');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Clean integer part
    integerPart = integerPart.replaceAll(RegExp(r'[^0-9]'), '');

    // Remove leading zeros
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
    }

    if (integerPart.isEmpty) {
      integerPart = '0';
    }

    // Format integer part
    final StringBuffer formattedInteger = StringBuffer();
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formattedInteger.write('.');
      }
      formattedInteger.write(integerPart[i]);
      count++;
    }

    String result = formattedInteger.toString().split('').reversed.join('');

    // Add decimal part (max 2 places for percentage)
    if (decimalPart != null) {
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
      decimalPart = decimalPart.replaceAll(RegExp(r'[^0-9]'), '');
      if (decimalPart.isNotEmpty) {
        result = '$result,$decimalPart';
      }
    }

    // Add negative sign if needed
    if (isNegative) {
      result = '-$result';
    }

    // Add % symbol
    result = '$result%';

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(
          offset: result.length - 1), // Position before %
    );
  }
}
