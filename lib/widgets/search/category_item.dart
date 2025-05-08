import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final Color color;
  final String imageAsset;

  const CategoryItem({
    super.key,
    required this.title,
    required this.color,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          // Background color
          Container(
            color: color,
          ),
          
          // Category image
          Positioned(
            right: -15,
            bottom: -10,
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset(
                imageAsset,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ),
          ),
          
          // Category title
          Positioned(
            top: 12,
            left: 12,
            child: Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}