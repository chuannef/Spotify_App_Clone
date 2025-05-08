import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/search/category_item.dart';

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
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    // TODO: Implement search functionality
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