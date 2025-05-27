import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppImage extends StatelessWidget {
  final String imageAsset;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    Key? key,
    required this.imageAsset,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        imageAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $imageAsset, Error: $error');
          return Container(
            width: width,
            height: height,
            color: AppColors.spotifyGrey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: AppColors.spotifyWhite,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Image not found',
                    style: TextStyle(
                      color: AppColors.spotifyWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
