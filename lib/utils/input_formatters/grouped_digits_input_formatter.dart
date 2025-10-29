import 'package:flutter/services.dart';

/// A TextInputFormatter that groups digits with a separator every [groupSize]
/// while preserving a leading plus sign (e.g. +84 347 015 943).
class GroupedDigitsInputFormatter extends TextInputFormatter {
  final int groupSize;
  final String separator;
  final bool preserveLeadingPlus;
  final int? maxDigits;

  GroupedDigitsInputFormatter({
    this.groupSize = 3,
    this.separator = ' ',
    this.preserveLeadingPlus = true,
    this.maxDigits,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final hasPlus = preserveLeadingPlus && text.startsWith('+');

    // Count digits before the cursor to compute the new caret position.
    final cursor = newValue.selection.baseOffset.clamp(0, text.length);
    final beforeCursor = text.substring(0, cursor);
    final digitsBeforeCursor = beforeCursor.replaceAll(RegExp(r'[^0-9]'), '');

    // Extract digits for formatting (ignore non-digits).
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (maxDigits != null && digits.length > maxDigits!) {
      digits = digits.substring(0, maxDigits);
    }

    final buffer = StringBuffer();
    if (hasPlus) buffer.write('+');

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final isLast = i == digits.length - 1;
      if (!isLast && ((i + 1) % groupSize == 0)) {
        buffer.write(separator);
      }
    }

    final formatted = buffer.toString();

    // Map digits-before-cursor to the new formatted offset.
    int newOffset = (hasPlus ? 1 : 0);
    if (digitsBeforeCursor.isNotEmpty) {
      final dCount = digitsBeforeCursor.length;
      // Every completed group adds one separator.
      newOffset += dCount + ((dCount - 1) ~/ groupSize);
    }
    if (newOffset > formatted.length) {
      newOffset = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  }
}