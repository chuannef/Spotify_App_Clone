import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../screens/album_detail_screen.dart';
import '../../screens/player_screen.dart';

class FeaturedPlaylistItem extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final bool isCircular; // Thêm thuộc tính để chỉ định hình dạng
  final String id; // Added album ID parameter

  const FeaturedPlaylistItem({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.id, // Make id required
    this.isCircular = false, // Mặc định là hình vuông
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Album image with gesture detection
              GestureDetector(
                onTap: () {
                  // Chỉ chuyển đến trang chi tiết nếu không phải nghệ sĩ
                  if (!isCircular) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailScreen(
                          id: id, // Pass the album ID
                          title: title,
                          description: description,
                          imageAsset: imageAsset,
                        ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  // Sử dụng borderRadius tròn nếu isCircular = true
                  borderRadius: BorderRadius.circular(isCircular ? 80 : 4),
                  child: Image.asset(
                    imageAsset,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    // Nếu không tìm thấy ảnh, hiển thị ảnh placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 160,
                        // Sử dụng hình tròn cho placeholder nếu isCircular = true
                        decoration: BoxDecoration(
                          color: AppColors.spotifyGrey,
                          borderRadius: BorderRadius.circular(isCircular ? 80 : 4),
                        ),
                        child: Center(
                          child: Icon(
                            // Hiển thị icon người nếu là hình tròn (nghệ sĩ)
                            isCircular ? Icons.person : Icons.queue_music,
                            color: AppColors.spotifyWhite,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Play button overlay cho album (không hiển thị cho nghệ sĩ)
              if (!isCircular)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.spotifyGreen,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: AppColors.spotifyBlack,
                      ),
                      iconSize: 24,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(                            builder: (context) => PlayerScreen(
                              title: title,
                              imageAsset: imageAsset,
                              albumTitle: title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.spotifyWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: AppTextStyles.smallText.copyWith(
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}