import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RecentlyPlayedItem extends StatelessWidget {
  final String title;
  final String imageAsset;
  final bool isPlaylist;

  const RecentlyPlayedItem({
    super.key,
    required this.title,
    required this.imageAsset,
    this.isPlaylist = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isPlaylist ? 4 : 50),
          child: Image.asset(
            imageAsset,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            // Thêm debug thông tin lỗi
            errorBuilder: (context, error, stackTrace) {
              // In lỗi ra console để debug
              print('Lỗi tải hình ảnh: $imageAsset, Lỗi: $error');
              
              return Container(
                width: 100,
                height: 100,
                color: isPlaylist ? AppColors.spotifyGrey : Colors.grey.shade800,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPlaylist ? Icons.queue_music : Icons.person,
                        color: AppColors.spotifyWhite,
                        size: 40,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Không tìm thấy',
                        style: TextStyle(
                          color: AppColors.spotifyWhite,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.spotifyWhite,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}