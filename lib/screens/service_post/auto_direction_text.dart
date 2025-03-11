// Create a custom widget that automatically handles text direction
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AutoDirectionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const AutoDirectionText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // First character directionality heuristic (simple approach)
    final direction = _isRTL(text) ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? (direction == TextDirection.rtl ? TextAlign.right : TextAlign.left),
      ),
    );
  }

  // Check if text appears to be RTL
  bool _isRTL(String text) {
    if (text.isEmpty) return false;

    // Skip common non-letter characters at the beginning
    int startIndex = 0;
    while (startIndex < text.length) {
      final char = text[startIndex];
      if (char == ' ' || char == '-' || char == '.' || char == ',' ||
          char == '!' || char == '?' || char == '#' || char == '@' ||
          char == '(' || char == ')' || char == '[' || char == ']') {
        startIndex++;
      } else {
        break;
      }
    }

    if (startIndex >= text.length) return false;

    // Get the Unicode code point of the first real character
    final firstCharCode = text.codeUnitAt(startIndex);

    // Arabic Unicode range: 0x0600–0x06FF
    // Persian/Farsi and Urdu share much of the Arabic range
    // Hebrew Unicode range: 0x0590–0x05FF
    return (firstCharCode >= 0x0590 && firstCharCode <= 0x06FF) ||
        // Additional ranges for other RTL languages like Arabic presentation forms
        (firstCharCode >= 0xFB50 && firstCharCode <= 0xFDFF) ||
        (firstCharCode >= 0xFE70 && firstCharCode <= 0xFEFF);
  }
}

// More comprehensive alternative implementation that considers multiple characters
class BetterAutoDirectionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const BetterAutoDirectionText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check the majority of characters to determine direction
    final direction = _getTextDirection(text);

    return Directionality(
      textDirection: direction,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? (direction == TextDirection.rtl ? TextAlign.right : TextAlign.left),
      ),
    );
  }

  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;

    int rtlCount = 0;
    int ltrCount = 0;

    // Count RTL and LTR characters
    for (int i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);

      // Skip spaces and common punctuation
      if (charCode == 32 || (charCode >= 33 && charCode <= 47) ||
          (charCode >= 58 && charCode <= 64) || (charCode >= 91 && charCode <= 96) ||
          (charCode >= 123 && charCode <= 126)) {
        continue;
      }

      // Arabic, Hebrew, and other RTL scripts
      if ((charCode >= 0x0590 && charCode <= 0x06FF) ||
          (charCode >= 0xFB50 && charCode <= 0xFDFF) ||
          (charCode >= 0xFE70 && charCode <= 0xFEFF)) {
        rtlCount++;
      }
      // Latin, Greek, Cyrillic, and other LTR scripts
      else if ((charCode >= 0x0041 && charCode <= 0x007A) || // Basic Latin
          (charCode >= 0x00C0 && charCode <= 0x024F) ||  // Latin extensions
          (charCode >= 0x0370 && charCode <= 0x03FF) ||  // Greek
          (charCode >= 0x0400 && charCode <= 0x04FF)) {  // Cyrillic
        ltrCount++;
      }
    }

    // First 3 real characters heuristic - for very short texts
    if (rtlCount + ltrCount <= 3) {
      for (int i = 0; i < text.length && i < 10; i++) {
        final charCode = text.codeUnitAt(i);
        if ((charCode >= 0x0590 && charCode <= 0x06FF) ||
            (charCode >= 0xFB50 && charCode <= 0xFDFF) ||
            (charCode >= 0xFE70 && charCode <= 0xFEFF)) {
          return TextDirection.rtl;
        }
        // If we encounter a strong LTR character
        else if ((charCode >= 0x0041 && charCode <= 0x007A) ||
            (charCode >= 0x00C0 && charCode <= 0x024F)) {
          return TextDirection.ltr;
        }
      }
    }

    // Use majority rule
    return rtlCount > ltrCount ? TextDirection.rtl : TextDirection.ltr;
  }
}