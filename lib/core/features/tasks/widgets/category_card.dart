import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.category, this.onTap});

  IconData _getIconFromName(String name) {
    switch (name) {
      case "lightbulb_outline":
        return Icons.lightbulb_outline;
      case "restaurant_outlined":
        return Icons.restaurant_outlined;
      case "work_outline":
        return Icons.work_outline;
      case "fitness_center":
        return Icons.fitness_center;
      case "music_note_outlined":
        return Icons.music_note_outlined;
      default:
        return Icons.circle; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _getIconFromName(category.icon),
              size: 32,
              color: const Color(0xFF4B4DED),
            ),

            const SizedBox(width: 16),

            // ---------------------------------------
            // NAME + "x on this week"
            // ---------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${category.count} on this week",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Arrow on the right
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
