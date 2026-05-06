import 'dart:math';
import 'package:flutter/material.dart';

enum ProgressBarStyle {
  glowDot,
  segmented,
  stripes,
  thinLine,
  stepped,
  circular,
  wave,
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    this.value = 0.0,
    this.style = ProgressBarStyle.glowDot,
    this.color,
    this.backgroundColor,
    this.height,
    this.width,
    this.showLabel = true,
    this.label,
    this.labelStyle,
    this.segmentCount = 20,
    this.stepLabels = const ['Start', 'Quarter', 'Half', 'Almost', 'Done'],
    this.circularLabel,
    this.strokeWidth = 8,
    this.radius = 32,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeInOut,
    this.borderRadius,
    this.indeterminate = false,
  }) : assert(
  indeterminate || (value >= 0.0 && value <= 1.0),
  'value must be between 0.0 and 1.0 when indeterminate is false',
  );

  final double value;
  final ProgressBarStyle style;
  final Color? color;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final int segmentCount;
  final List<String> stepLabels;
  final String? circularLabel;
  final double strokeWidth;
  final double radius;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;
  final BorderRadius? borderRadius;

  /// No known progress — shows an animated shimmer/sweep instead
  final bool indeterminate;

  Color _defaultColor(ProgressBarStyle s) {
    switch (s) {
      case ProgressBarStyle.glowDot:   return const Color(0xFF1D9E75);
      case ProgressBarStyle.segmented: return const Color(0xFF378ADD);
      case ProgressBarStyle.stripes:   return const Color(0xFFD4537E);
      case ProgressBarStyle.thinLine:  return const Color(0xFFBA7517);
      case ProgressBarStyle.stepped:   return const Color(0xFF534AB7);
      case ProgressBarStyle.circular:  return const Color(0xFF378ADD);
      case ProgressBarStyle.wave:      return const Color(0xFF1D9E75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _defaultColor(style);

    if (indeterminate) {
      return SizedBox(
        width: width,
        child: style == ProgressBarStyle.circular
            ? _IndeterminateCircular(
          color: effectiveColor,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          radius: radius,
        )
            : _IndeterminateLinear(
          color: effectiveColor,
          backgroundColor: backgroundColor,
          height: height ?? _defaultHeight(style),
          borderRadius: borderRadius,
          style: style,
          segmentCount: segmentCount,
        ),
      );
    }

    final child = animate
        ? TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: animationDuration,
      curve: animationCurve,
      builder: (ctx, v, _) => _buildStyle(ctx, effectiveColor, v),
    )
        : _buildStyle(context, effectiveColor, value);

    return SizedBox(width: width, child: child);
  }

  double _defaultHeight(ProgressBarStyle s) {
    switch (s) {
      case ProgressBarStyle.segmented: return 12;
      case ProgressBarStyle.stripes:   return 18;
      case ProgressBarStyle.stepped:   return 8;
      case ProgressBarStyle.wave:      return 24;
      default:                         return 10;
    }
  }

  Widget _buildStyle(BuildContext context, Color c, double v) {
    switch (style) {
      case ProgressBarStyle.glowDot:   return _GlowDot(value: v, color: c, backgroundColor: backgroundColor, height: height ?? 10, showLabel: showLabel, label: label, labelStyle: labelStyle, borderRadius: borderRadius);
      case ProgressBarStyle.segmented: return _Segmented(value: v, color: c, backgroundColor: backgroundColor, height: height ?? 12, showLabel: showLabel, label: label, labelStyle: labelStyle, segmentCount: segmentCount);
      case ProgressBarStyle.stripes:   return _Stripes(value: v, color: c, backgroundColor: backgroundColor, height: height ?? 18, showLabel: showLabel, label: label, labelStyle: labelStyle, borderRadius: borderRadius);
      case ProgressBarStyle.thinLine:  return _ThinLine(value: v, color: c, backgroundColor: backgroundColor, showLabel: showLabel, label: label, labelStyle: labelStyle);
      case ProgressBarStyle.stepped:   return _Stepped(value: v, color: c, backgroundColor: backgroundColor, height: height ?? 8, showLabel: showLabel, label: label, labelStyle: labelStyle, stepLabels: stepLabels, borderRadius: borderRadius);
      case ProgressBarStyle.circular:  return _Circular(value: v, color: c, backgroundColor: backgroundColor, showLabel: showLabel, label: label ?? circularLabel, labelStyle: labelStyle, strokeWidth: strokeWidth, radius: radius);
      case ProgressBarStyle.wave:      return _Wave(value: v, color: c, backgroundColor: backgroundColor, height: height ?? 24, showLabel: showLabel, label: label, labelStyle: labelStyle, borderRadius: borderRadius);
    }
  }
}

// ── Indeterminate — Linear shimmer sweep ──────────────────────────────────────

class _IndeterminateLinear extends StatefulWidget {
  const _IndeterminateLinear({
    required this.color,
    required this.backgroundColor,
    required this.height,
    required this.borderRadius,
    required this.style,
    required this.segmentCount,
  });
  final Color color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final ProgressBarStyle style;
  final int segmentCount;

  @override
  State<_IndeterminateLinear> createState() => _IndeterminateLinearState();
}

class _IndeterminateLinearState extends State<_IndeterminateLinear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(999);
    final bg = widget.backgroundColor ?? Colors.grey.shade200;

    // Segmented gets its own indeterminate look — chasing dots
    if (widget.style == ProgressBarStyle.segmented) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final active = (_ctrl.value * widget.segmentCount).floor();
          return Row(
            children: List.generate(widget.segmentCount, (i) {
              final dist = (i - active).abs();
              final opacity = dist == 0 ? 1.0 : dist == 1 ? 0.5 : dist == 2 ? 0.2 : 0.0;
              return Expanded(
                child: Container(
                  height: widget.height,
                  margin: EdgeInsets.only(right: i < widget.segmentCount - 1 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: Color.lerp(bg, widget.color, opacity),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          );
        },
      );
    }

    // All other linear styles — smooth shimmer sweep
    return ClipRRect(
      borderRadius: br,
      child: Container(
        height: widget.height,
        color: bg,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            // bar travels from -40% to +140% of track width
            final position = _ctrl.value * 1.4 - 0.2;
            return FractionallySizedBox(
              alignment: FractionalOffset(position.clamp(0.0, 1.0), 0.5),
              widthFactor: 0.4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: br,
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withOpacity(0),
                      widget.color.withOpacity(0.9),
                      widget.color,
                      widget.color.withOpacity(0.9),
                      widget.color.withOpacity(0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Indeterminate — Circular spinning arc ─────────────────────────────────────

class _IndeterminateCircular extends StatefulWidget {
  const _IndeterminateCircular({
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.radius,
  });
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth, radius;

  @override
  State<_IndeterminateCircular> createState() => _IndeterminateCircularState();
}

class _IndeterminateCircularState extends State<_IndeterminateCircular>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = (widget.radius + widget.strokeWidth) * 2;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _IndeterminateCirclePainter(
            progress: _ctrl.value,
            color: widget.color,
            bg: widget.backgroundColor ?? Colors.grey.shade200,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _IndeterminateCirclePainter extends CustomPainter {
  _IndeterminateCirclePainter({
    required this.progress,
    required this.color,
    required this.bg,
    required this.strokeWidth,
  });
  final double progress, strokeWidth;
  final Color color, bg;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - strokeWidth / 2;

    // track
    canvas.drawCircle(c, r, Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth);

    // spinning arc — rotates and the arc length pulses
    final rotation = progress * 2 * pi * 1.5;
    final arcLen = (0.3 + 0.5 * sin(progress * 2 * pi).abs()) * 2 * pi * 0.6;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      rotation,
      arcLen,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_IndeterminateCirclePainter old) => old.progress != progress;
}

// ── helpers ───────────────────────────────────────────────────────────────────

String _pct(double v) => '${(v * 100).round()}%';

TextStyle _defaultLabel(Color c) => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  color: c,
);

// ── 1. Glow Dot ───────────────────────────────────────────────────────────────

class _GlowDot extends StatefulWidget {
  const _GlowDot({required this.value, required this.color, required this.backgroundColor, required this.height, required this.showLabel, required this.label, required this.labelStyle, required this.borderRadius});
  final double value, height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;

  @override
  State<_GlowDot> createState() => _GlowDotState();
}

class _GlowDotState extends State<_GlowDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  late final Animation<double> _opacity = Tween(begin: 0.7, end: 1.0).animate(_ctrl);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(999);
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: br,
          child: Container(
            height: widget.height,
            color: widget.backgroundColor ?? Colors.grey.shade200,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widget.value,
              child: AnimatedBuilder(
                animation: _opacity,
                builder: (_, __) => Opacity(
                  opacity: _opacity.value,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(decoration: BoxDecoration(color: widget.color, borderRadius: br)),
                    Positioned(
                      right: -widget.height * 0.7,
                      top: -(widget.height * 0.4),
                      child: Container(
                        width: widget.height * 1.4,
                        height: widget.height * 1.4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color,
                          boxShadow: [BoxShadow(color: widget.color.withOpacity(0.7), blurRadius: 10, spreadRadius: 2)],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.showLabel) ...[const SizedBox(width: 10), Text(widget.label ?? _pct(widget.value), style: widget.labelStyle ?? _defaultLabel(widget.color))],
    ]);
  }
}

// ── 2. Segmented ──────────────────────────────────────────────────────────────

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.color, required this.backgroundColor, required this.height, required this.showLabel, required this.label, required this.labelStyle, required this.segmentCount});
  final double value, height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final int segmentCount;

  @override
  Widget build(BuildContext context) {
    final filled = (value * segmentCount).round();
    return Row(children: [
      Expanded(
        child: Row(
          children: List.generate(segmentCount, (i) => Expanded(
            child: Container(
              height: height,
              margin: EdgeInsets.only(right: i < segmentCount - 1 ? 3 : 0),
              decoration: BoxDecoration(
                color: i < filled ? color : (backgroundColor ?? Colors.grey.shade200),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ),
      ),
      if (showLabel) ...[const SizedBox(width: 10), Text(label ?? _pct(value), style: labelStyle ?? _defaultLabel(color))],
    ]);
  }
}

// ── 3. Stripes ────────────────────────────────────────────────────────────────

class _Stripes extends StatefulWidget {
  const _Stripes({required this.value, required this.color, required this.backgroundColor, required this.height, required this.showLabel, required this.label, required this.labelStyle, required this.borderRadius});
  final double value, height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;

  @override
  State<_Stripes> createState() => _StripesState();
}

class _StripesState extends State<_Stripes> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(999);
    final light = Color.lerp(widget.color, Colors.white, 0.4)!;
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: br,
          child: Container(
            height: widget.height,
            color: widget.backgroundColor ?? Colors.grey.shade200,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widget.value,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _StripePainter(progress: _ctrl.value, color: widget.color, light: light),
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.showLabel) ...[const SizedBox(width: 10), Text(widget.label ?? _pct(widget.value), style: widget.labelStyle ?? _defaultLabel(widget.color))],
    ]);
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.progress, required this.color, required this.light});
  final double progress;
  final Color color, light;

  @override
  void paint(Canvas canvas, Size size) {
    const stripeW = 16.0;
    final offset = progress * stripeW * 2;
    final paint = Paint();
    for (double x = -stripeW * 2 + offset; x < size.width + stripeW; x += stripeW * 2) {
      paint.color = color;
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeW, size.height), paint);
      paint.color = light;
      canvas.drawRect(Rect.fromLTWH(x + stripeW, 0, stripeW, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.progress != progress;
}

// ── 4. Thin Line ──────────────────────────────────────────────────────────────

class _ThinLine extends StatefulWidget {
  const _ThinLine({required this.value, required this.color, required this.backgroundColor, required this.showLabel, required this.label, required this.labelStyle});
  final double value;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;

  @override
  State<_ThinLine> createState() => _ThinLineState();
}

class _ThinLineState extends State<_ThinLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  late final Animation<double> _bounce = Tween(begin: 0.0, end: -4.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Stack(alignment: Alignment.centerLeft, clipBehavior: Clip.none, children: [
          Container(height: 3, decoration: BoxDecoration(color: widget.backgroundColor ?? Colors.grey.shade200, borderRadius: BorderRadius.circular(999))),
          FractionallySizedBox(
            widthFactor: widget.value,
            child: Container(height: 3, decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(999))),
          ),
          Positioned(
            left: (widget.value * (MediaQuery.of(context).size.width - (widget.showLabel ? 60 : 20))) - 5,
            child: AnimatedBuilder(
              animation: _bounce,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _bounce.value),
                child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
              ),
            ),
          ),
        ]),
      ),
      if (widget.showLabel) ...[const SizedBox(width: 14), Text(widget.label ?? _pct(widget.value), style: widget.labelStyle ?? _defaultLabel(widget.color))],
    ]);
  }
}

// ── 5. Stepped ────────────────────────────────────────────────────────────────

class _Stepped extends StatelessWidget {
  const _Stepped({required this.value, required this.color, required this.backgroundColor, required this.height, required this.showLabel, required this.label, required this.labelStyle, required this.stepLabels, required this.borderRadius});
  final double value, height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final List<String> stepLabels;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(999);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: br,
            child: Container(
              height: height,
              color: backgroundColor ?? Colors.grey.shade200,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.white, 0.4)!]),
                  borderRadius: br,
                )),
              ),
            ),
          ),
        ),
        if (showLabel) ...[const SizedBox(width: 10), Text(label ?? _pct(value), style: labelStyle ?? _defaultLabel(color))],
      ]),
      const SizedBox(height: 6),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stepLabels.length, (i) {
          final threshold = i / (stepLabels.length - 1);
          final active = value >= threshold;
          return Text(stepLabels[i], style: TextStyle(fontSize: 11, color: active ? color : Colors.grey, fontWeight: active ? FontWeight.w500 : FontWeight.w400));
        }),
      ),
    ]);
  }
}

// ── 6. Circular ───────────────────────────────────────────────────────────────

class _Circular extends StatelessWidget {
  const _Circular({required this.value, required this.color, required this.backgroundColor, required this.showLabel, required this.label, required this.labelStyle, required this.strokeWidth, required this.radius});
  final double value, strokeWidth, radius;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final size = (radius + strokeWidth) * 2;
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _CirclePainter(value: value, color: color, bg: backgroundColor ?? Colors.grey.shade200, strokeWidth: strokeWidth),
        child: showLabel
            ? Center(child: Text(label ?? _pct(value), style: labelStyle ?? TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)))
            : null,
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter({required this.value, required this.color, required this.bg, required this.strokeWidth});
  final double value, strokeWidth;
  final Color color, bg;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) / 2 - strokeWidth / 2;
    final bgPaint = Paint()..color = bg ..style = PaintingStyle.stroke ..strokeWidth = strokeWidth ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()..color = color ..style = PaintingStyle.stroke ..strokeWidth = strokeWidth ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bgPaint);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * value, false, fgPaint);
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.value != value;
}

// ── 7. Wave ───────────────────────────────────────────────────────────────────

class _Wave extends StatefulWidget {
  const _Wave({required this.value, required this.color, required this.backgroundColor, required this.height, required this.showLabel, required this.label, required this.labelStyle, required this.borderRadius});
  final double value, height;
  final Color color;
  final Color? backgroundColor;
  final bool showLabel;
  final String? label;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;

  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(999);
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: br,
          child: Container(
            height: widget.height,
            color: widget.backgroundColor ?? Colors.grey.shade200,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widget.value,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    painter: _WavePainter(progress: _ctrl.value, color: widget.color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.showLabel) ...[const SizedBox(width: 10), Text(widget.label ?? _pct(widget.value), style: widget.labelStyle ?? _defaultLabel(widget.color))],
    ]);
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final waveH = size.height * 0.4;
    final shift = progress * size.width * 2;
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + sin((x + shift) / size.width * 2 * pi * 2) * waveH;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}