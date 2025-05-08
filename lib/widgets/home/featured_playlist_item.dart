import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class FeaturedPlaylistItem extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final bool isCircular; // Thêm thuộc tính để chỉ định hình dạng

  const FeaturedPlaylistItem({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.isCircular = false, // Mặc định là hình vuông
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
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