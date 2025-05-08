import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../screens/album_detail_screen.dart';
import '../../screens/player_screen.dart';

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
    return InkWell(
      onTap: () {
        // Chuyển đến trang chi tiết khi click vào item
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(
              title: title,
              description: description, 
              imageAsset: imageAsset,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Playlist image
            Stack(
              children: [
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
                
                // Play button overlay
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.spotifyGreen,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        // Chuyển đến trang phát nhạc khi click vào nút play
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayerScreen(
                              title: title,
                              imageAsset: imageAsset,
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.spotifyBlack,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }
}