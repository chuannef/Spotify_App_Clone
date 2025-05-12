import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/search/category_item.dart';
import 'search_results_screen.dart';

class MusicSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search songs, artists or albums';
  
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.spotifyWhite,
          fontSize: 18,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.spotifyBlack,
        iconTheme: IconThemeData(color: AppColors.spotifyWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: AppColors.spotifyWhite.withOpacity(0.7),
        ),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: AppColors.spotifyBlack,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          'Enter a search term to begin',
          style: AppTextStyles.bodyText,
        ),
      );
    }

    // Chuyển đến trang kết quả tìm kiếm
    return SearchResultsScreen(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Searches',
              style: AppTextStyles.subHeading,
            ),
          ),
          const ListTile(
            leading: Icon(Icons.history, color: AppColors.spotifyLightGrey),
            title: Text('Vũ.', style: TextStyle(color: AppColors.spotifyWhite)),
            subtitle: Text('Artist', style: TextStyle(color: AppColors.spotifyLightGrey)),
          ),
          const ListTile(
            leading: Icon(Icons.history, color: AppColors.spotifyLightGrey),
            title: Text('Lặng', style: TextStyle(color: AppColors.spotifyWhite)),
            subtitle: Text('Album', style: TextStyle(color: AppColors.spotifyLightGrey)),
          ),
          const ListTile(
            leading: Icon(Icons.history, color: AppColors.spotifyLightGrey),
            title: Text('Mười Năm', style: TextStyle(color: AppColors.spotifyWhite)),
            subtitle: Text('Song', style: TextStyle(color: AppColors.spotifyLightGrey)),
          ),
        ],
      );
    }

    // Hiển thị các gợi ý khi gõ
    final suggestions = _getSuggestions(query);
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: Icon(
            suggestion['type'] == 'Artist' ? Icons.person 
                : suggestion['type'] == 'Album' ? Icons.album 
                : Icons.music_note,
            color: AppColors.spotifyWhite,
          ),          title: Text(
            suggestion['title'] ?? '',
            style: const TextStyle(color: AppColors.spotifyWhite),
          ),
          subtitle: Text(
            suggestion['type'] ?? '',
            style: const TextStyle(color: AppColors.spotifyLightGrey),
          ),
          onTap: () {
            query = suggestion['title'] ?? '';
            showResults(context);
          },
        );
      },
    );
  }
  // Method to get search suggestions
  List<Map<String, String>> _getSuggestions(String query) {
    final lowercaseQuery = query.toLowerCase();
    final List<Map<String, String>> allItems = [
      {'title': 'Vũ.', 'type': 'Artist'},
      {'title': 'Đen Vâu', 'type': 'Artist'},
      {'title': 'Bray', 'type': 'Artist'},
      {'title': 'Bảo Tàng Của Nuối Tiếc', 'type': 'Album'},
      {'title': 'Show của Đen', 'type': 'Album'},
      {'title': 'Lặng', 'type': 'Album'},
      {'title': 'Nếu Những Tiếc Nuối', 'type': 'Song'},
      {'title': 'Mùa Mưa Ấy', 'type': 'Song'},
      {'title': 'Ngồi Chờ Trong Vấn Vương - feat. Mỹ Anh', 'type': 'Song'},
      {'title': 'Dành Hết Xuân Thì Để Chờ Nhau - feat. Hà Anh Tuấn', 'type': 'Song'},
      {'title': 'Những Lời Hứa Bỏ Quên - feat. Dear Jane', 'type': 'Song'},
      {'title': 'Bình Yên - feat. Binz', 'type': 'Song'},
      {'title': 'Mơ (ft. Hậu Vi)', 'type': 'Song'},
      {'title': 'Ngày Lang Thang', 'type': 'Song'},
      {'title': '10 Triệu Năm', 'type': 'Song'},
      {'title': 'Mười Năm (ft. Ngọc Linh)', 'type': 'Song'},
      {'title': '1000 Ánh Mắt (ft. Obito)', 'type': 'Song'},
      {'title': 'Anh Vẫn Đợi', 'type': 'Song'},
      {'title': 'Có Đôi Điều', 'type': 'Song'},
      {'title': 'Lặng', 'type': 'Song'},
      {'title': 'Night Time', 'type': 'Song'},
    ];

    return allItems
        .where((item) => item['title']!.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.spotifyBlack,
            pinned: true,
            floating: true,
            title: Text(
              'Search',
              style: AppTextStyles.heading.copyWith(fontSize: 24),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: MusicSearchDelegate(),
                    );
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.spotifyWhite,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: AppColors.spotifyBlack),
                        const SizedBox(width: 12),
                        Text(
                          'What do you want to listen to?',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.spotifyBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Browse All Section
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse All',
                    style: AppTextStyles.subHeading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Categories Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildListDelegate([
                const CategoryItem(
                  title: 'Pop',
                  color: Colors.pinkAccent,
                  imageAsset: 'assets/images/pop.png',
                ),
                const CategoryItem(
                  title: 'Hip-Hop',
                  color: Color.fromARGB(255, 216, 145, 52),
                  imageAsset: 'assets/images/hip.png',
                ),
                const CategoryItem(
                  title: 'K-Pop',
                  color: Colors.redAccent,
                  imageAsset: 'assets/images/kpop.png',
                ),
                const CategoryItem(
                  title: 'Hip-hop Việt',
                  color: Color.fromARGB(255, 50, 66, 126),
                  imageAsset: 'assets/images/hhv.png',
                ),
                const CategoryItem(
                  title: 'Happy Music',
                  color: Color.fromARGB(255, 27, 62, 34),
                  imageAsset: 'assets/images/hp.png',
                ),
                const CategoryItem(
                  title: 'Nhạc Không Lời',
                  color: Color.fromARGB(255, 84, 134, 140),
                  imageAsset: 'assets/images/kl.png',
                ),
                const CategoryItem(
                  title: 'Tâm Trạng',
                  color: Colors.greenAccent,
                  imageAsset: 'assets/images/main/fell.png',
                ),
                const CategoryItem(
                  title: 'New Releases',
                  color: Color.fromARGB(255, 222, 186, 243),
                  imageAsset: 'assets/images/main/relax.png',
                ),
                const CategoryItem(
                  title: 'Tập Trung',
                  color: Color.fromARGB(255, 142, 203, 121),
                  imageAsset: 'assets/images/tt.png',
                ),
                const CategoryItem(
                  title: 'Yên Bình',
                  color: Color.fromARGB(255, 196, 220, 107),
                  imageAsset: 'assets/images/main/peach.png',
                ),
              ]),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 1)),
        ],
      ),
    );
  }
}