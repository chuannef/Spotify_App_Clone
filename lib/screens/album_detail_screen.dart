import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'player_screen.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;

  const AlbumDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: CustomScrollView(
        slivers: [
          // Appbar with album image and gradient
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album Image
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.spotifyBlack.withOpacity(0.5),
                          AppColors.spotifyBlack,
                        ],
                      ),
                    ),
                  ),
                  // Album title and description
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTextStyles.bodyText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: AppColors.spotifyBlack,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Album controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        color: AppColors.spotifyLightGrey,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.file_download_outlined,
                        color: AppColors.spotifyLightGrey,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.more_vert,
                        color: AppColors.spotifyLightGrey,
                      ),
                    ],
                  ),
                  // Play button that navigates to player screen
                  FloatingActionButton(
                    backgroundColor: AppColors.spotifyGreen,
                    onPressed: () {
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
                    mini: false,
                    child: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.spotifyLightGrey,
                    ),
                  ),
                  title: Text(
                    'Track ${index + 1}',
                    style: AppTextStyles.bodyText,
                  ),
                  subtitle: Text(
                    '${(index % 3 + 2) * 100 + (index % 5) * 11}K plays',
                    style: AppTextStyles.smallText,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.spotifyLightGrey,
                    ),
                    onPressed: () {},
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          title: 'Track ${index + 1} - $title',
                          imageAsset: imageAsset,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: 10, // Giả lập 10 bài hát
            ),
          ),
        ],
      ),
    );
  }
}