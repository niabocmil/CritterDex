import 'package:flutter/material.dart';

import '../data/database.dart';
import 'terrarium_layout.dart';

/// Fraction (0..1) of [shelf]'s total capacity (length × levels) used by
/// [terrariums] + [tools] currently placed on it.
double occupancyFractionFor(
  Shelf shelf,
  List<Terrarium> terrariums,
  List<Tool> tools,
) {
  final used = terrariums.fold<double>(0.0, (sum, t) => sum + footprintWidthCm(t)) +
      tools.fold<double>(0.0, (sum, t) => sum + t.lengthCm);
  final capacity = shelf.lengthCm * shelf.levelCount;
  return capacity == 0 ? 0.0 : (used / capacity).clamp(0.0, 1.0);
}

/// Green up to 60%, gradient green -> yellow -> red from 60% to 95%, solid
/// red from 95% to 100%.
Color occupancyColor(double fraction) {
  final pct = fraction * 100;
  if (pct <= 60) return Colors.green;
  if (pct >= 95) return Colors.red;
  final t = (pct - 60) / (95 - 60);
  if (t <= 0.5) {
    return Color.lerp(Colors.green, Colors.yellow, t / 0.5)!;
  }
  return Color.lerp(Colors.yellow, Colors.red, (t - 0.5) / 0.5)!;
}
