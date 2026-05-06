import 'package:flutter/material.dart';

class SubmitNotAvailable extends StatelessWidget {
  const SubmitNotAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 32,
            color: Color(0xFFB0B0B0),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Submission Unavailable',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'This option is currently not available.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}