import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PlaylistItem extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;

  const PlaylistItem({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Playlist image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              imageAsset,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 65,
                  height: 65,
                  color: AppColors.spotifyGrey,
                  child: const Center(
                    child: Icon(
                      Icons.queue_music,
                      color: AppColors.spotifyWhite,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.smallText,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // More button
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.spotifyLightGrey,
            ),
            onPressed: () {
              // TODO: Show playlist options
            },
          ),
        ],
      ),
    );
  }
}