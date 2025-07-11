import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../screens/album_detail_screen.dart';
import '../../screens/player_screen.dart';
import '../../screens/track_selection_screen.dart'; // Added for track selection

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
  });  @override
  Widget build(BuildContext context) {
    // Check if this is a special album that should use track selection first
    final isPhepMauAlbum = id == 'album_phep_mau';
    final isJumpingMachineAlbum = id == 'album_jumping_machine';
    final needsTrackSelection = isPhepMauAlbum || isJumpingMachineAlbum;
    
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Album image with gesture detection
              GestureDetector(
                onTap: () {                  // Navigation to track selection for special albums
                  if (needsTrackSelection) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackSelectionScreen(
                          albumId: id,
                          albumTitle: title,
                          albumDescription: description,
                          imageAsset: imageAsset,
                        ),
                      ),
                    );
                  } 
                  // Regular album detail navigation for others
                  else if (!isCircular) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailScreen(
                          id: id,
                          title: title,
                          description: description,
                          imageAsset: imageAsset,
                        ),
                      ),
                    );
                  }
                },child: ClipRRect(
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
                      padding: const EdgeInsets.all(4),                      constraints: const BoxConstraints(),                      onPressed: () {
                        // Navigation to track selection for special albums
                        if (needsTrackSelection) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackSelectionScreen(
                                albumId: id,
                                albumTitle: title,
                                albumDescription: description,
                                imageAsset: imageAsset,
                              ),
                            ),
                          );
                        } else {
                          // Get total tracks based on album title
                          int totalTracksCount;
                          if (title.toLowerCase().contains('bảo tàng của nuối tiếc')) {
                            totalTracksCount = 6;
                          } else if (title.toLowerCase().contains('lặng')) {
                            totalTracksCount = 5;
                          } else if (title.toLowerCase().contains('show của đen')) {
                            totalTracksCount = 4;
                          } else if (title.toLowerCase().contains('phép màu')) {
                            totalTracksCount = 1;
                          } else {
                            totalTracksCount = 10; // Default for other albums
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerScreen(
                                title: title,
                                imageAsset: imageAsset,
                                currentTrack: 1, // Start with first track
                                totalTracks: totalTracksCount,
                                albumTitle: title,
                              ),
                            ),
                          );
                        }
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
          ),        ],
      ),
    );  
  }
}