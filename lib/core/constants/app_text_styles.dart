import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle quote(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineMedium ??
        const TextStyle(fontSize: 26, fontWeight: FontWeight.w600);
    return GoogleFonts.playfairDisplay(
      textStyle: base.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }

  static TextStyle author(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    return GoogleFonts.lato(
      textStyle: base.copyWith(
        fontStyle: FontStyle.italic,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  static TextStyle body(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    return GoogleFonts.lato(textStyle: base);
  }

  static TextStyle sectionTitle(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    return GoogleFonts.lato(
      textStyle: base.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

