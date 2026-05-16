import 'package:flutter/material.dart';

class SubmitNotAvailable extends StatelessWidget {
  const SubmitNotAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFAFA9EC),
                  const Color(0xFF5DCAA5),
                  const Color(0xFFF0997B),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 30,
                    color: Color(0xFF9E9E9E),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'You cant submit card today ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'You can’t submit the card today. Cards can only be submitted once per day..',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9E9E),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons row
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     _ActionButton(label: 'Learn more', onTap: () {}),
                //     // const SizedBox(width: 8),
                //     // _ActionButton(label: 'Contact support', onTap: () {}),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

