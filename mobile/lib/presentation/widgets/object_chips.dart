import 'package:flutter/material.dart';

import '../../../domain/entities/detected_object.dart';

class ObjectChips extends StatelessWidget {
  const ObjectChips({super.key, required this.objects});

  final List<DetectedObject> objects;

  @override
  Widget build(BuildContext context) {
    if (objects.isEmpty) {
      return const SizedBox(height: 8);
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: objects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final object = objects[index];
          return Chip(
            avatar: Icon(
              object.isCar ? Icons.directions_car : Icons.label_outline,
              size: 18,
            ),
            label: Text('${object.labelEs} ${object.confidencePct.round()}%'),
            color: object.isCar
                ? WidgetStateProperty.all(const Color(0xFF166534))
                : null,
          );
        },
      ),
    );
  }
}
