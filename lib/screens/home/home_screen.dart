import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/home/recently_played_item.dart';
import '../../widgets/home/featured_playlist_item.dart';
import '../../widgets/home/scrollable_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.spotifyBlack,
            expandedHeight: 120,
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Good evening',
                    style: AppTextStyles.heading.copyWith(fontSize: 24),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: AppColors.spotifyWhite),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.history, color: AppColors.spotifyWhite),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.spotifyWhite),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Radio phổ biến Section with scroll arrows
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            sliver: SliverToBoxAdapter(
              child: ScrollableSection(
                title: 'Radio phổ biến',
                height: 140,
                children: const [
                  RecentlyPlayedItem(
                    title: 'Với Thịnh Suy, Da LAB, Chillies và nhiều hơn nữa', 
                    imageAsset: 'assets/images/vu.png',
                    isPlaylist: true,
                  ),
                  SizedBox(width: 16),
                  RecentlyPlayedItem(
                    title: 'Với HIEUTHUHAI, Ronboogz, MANBO và nhiều hơn nữa', 
                    imageAsset: 'assets/images/bray.png',
                    isPlaylist: true,
                  ),
                  SizedBox(width: 16),
                  RecentlyPlayedItem(
                    title: 'Với tlinh, RPT MCK, Wxrdie và nhiều hơn nữa', 
                    imageAsset: 'assets/images/low.png',
                    isPlaylist: true,
                  ),
                  SizedBox(width: 16),
                  RecentlyPlayedItem(
                    title: 'Với RPT MCK, Wren Evans, GREY D và nhiều hơn nữa', 
                    imageAsset: 'assets/images/tli.png',
                    isPlaylist: true,
                  ),
                  SizedBox(width: 16),
                  RecentlyPlayedItem(
                    title: 'Với SOOBIN, HIEUTHUHAI, JustaTee và nhiều hơn nữa', 
                    imageAsset: 'assets/images/st.png',
                    isPlaylist: true,
                  ),
                  SizedBox(width: 16),
                  RecentlyPlayedItem(
                    title: 'Với Bùi Anh Tuấn, Vũ., Noo Phước Thịnh và nhiều hơn nữa', 
                    imageAsset: 'assets/images/ha.png',
                    isPlaylist: true,
                  ),
                ],
              ),
            ),
          ),

          // Album và đĩa nổi tiếng Section with scroll arrows
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
            sliver: SliverToBoxAdapter(
              child: ScrollableSection(
                title: 'Album và đĩa nổi tiếng',
                height: 210,
                children: const [
                  FeaturedPlaylistItem(
                    id: 'album_show_cua_den',
                    title: 'Show của Đen',
                    description: 'Liveshow "Show của Đen" tại Nhà thi đấu',
                    imageAsset: 'assets/images/den.png',
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'album_jumping_machine',
                    title: 'Jumping machine',
                    description: 'New music from artists you follow',
                    imageAsset: 'assets/images/JP.png',
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'album_bao_tang',
                    title: 'Bảo Tàng Của Nuối Tiếc',
                    description: 'New music from artists you follow',
                    imageAsset: 'assets/images/tn.png',
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'album_discover_weekly',
                    title: 'Discover Weekly',
                    description: 'Your weekly mixtape of fresh music',
                    imageAsset: 'assets/images/dd.png',
                  ),
                ],
              ),
            ),
          ),

          // Nghệ sĩ nổi bật Section with scroll arrows
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 24),
            sliver: SliverToBoxAdapter(
              child: ScrollableSection(
                title: 'Nghệ sĩ nổi bật',
                height: 210,
                children: const [
                  FeaturedPlaylistItem(
                    id: 'artist_vu',
                    title: 'Vũ',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/vf.png',
                    isCircular: true,
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'artist_den_vau',
                    title: 'Đen Vâu',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/den.png',
                    isCircular: true,
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'artist_bray',
                    title: 'Bray',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/br.png',
                    isCircular: true,
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'artist_hieuthuhai',
                    title: 'Hieuthuhai',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/h2.png',
                    isCircular: true,
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'artist_tlinh',
                    title: 'Tlinh',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/t.png',
                    isCircular: true,
                  ),
                  SizedBox(width: 16),
                  FeaturedPlaylistItem(
                    id: 'artist_amee',
                    title: 'Amee',
                    description: 'Nghệ sĩ',
                    imageAsset: 'assets/images/ame.png',
                    isCircular: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}