// lib/utils/size_config.dart
import 'dart:math';

import 'package:flutter/material.dart';

extension ScreenSize on BuildContext {
  static const double _designWidth  = 393.0;
  static const double _designHeight = 852.0;

  // ─── Tablet breakpoint ───────────────────────────────────────────────────
  bool get isTabletDevice => MediaQuery.of(this).size.shortestSide >= 600;

  // ─── Raw screen info ─────────────────────────────────────────────────────
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // ─── Scale factors ───────────────────────────────────────────────────────
  double get _scaleWidth  => screenWidth  / _designWidth;
  double get _scaleHeight => screenHeight / _designHeight;

  // Tablet cap: prevent UI from scaling infinitely on large screens
  double get _tabletScaleCap => isTabletDevice ? 1.4 : 1.0;

  double get _scaleText => min(_scaleWidth, _scaleHeight) * _tabletScaleCap;

  // ─── Core converters ─────────────────────────────────────────────────────

  /// Width-based — horizontal sizes, padding, widths
  double w(double px) => px * (_scaleWidth).clamp(0.7, _tabletScaleCap);

  /// Height-based — vertical sizes, heights
  double h(double px) => px * (_scaleHeight).clamp(0.7, _tabletScaleCap);

  /// Font size — matches Figma px, clamped for tablets
  double sp(double px) => px * min(_scaleWidth, _scaleHeight).clamp(0.8, 1.3);

  // ─── Responsive layout helpers ────────────────────────────────────────────

  /// Max content width — centers content on large tablets like iPad Pro
  double get maxContentWidth => isTabletDevice
      ? screenWidth.clamp(0, 600)
      : screenWidth;

  /// Horizontal page padding — wider on tablets
  double get pagePadding => isTabletDevice ? w(48) : w(20);

  /// Column count for grids
  int get gridColumns => isTabletDevice ? 2 : 1;

  // ─── Spacing ──────────────────────────────────────────────────────────────
  double get spacing4  => w(4);
  double get spacing8  => w(8);
  double get spacing12 => w(12);
  double get spacing16 => w(16);
  double get spacing24 => w(24);
  double get spacing32 => w(32);

  // ─── Card dimensions ─────────────────────────────────────────────────────
  double get cardWidth  => isTabletDevice ? screenWidth * 0.18 : screenWidth * 0.25;
  double get cardHeight => cardWidth * 1.5;

  // ─── Deprecated ──────────────────────────────────────────────────────────
  double widthPercentage(double percentage)  => screenWidth  * (percentage / 100);
  double heightPercentage(double percentage) => screenHeight * (percentage / 100);
  double responsiveSize(double size)         => sp(size);
  double responsiveFontSize(double size)     => sp(size);
}