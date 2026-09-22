import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.text,
    required this.hasCar,
  });

  final String text;
  final bool hasCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: hasCar ? const Color(0xFF14532D) : const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
