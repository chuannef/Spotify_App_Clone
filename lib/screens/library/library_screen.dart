import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/library/playlist_item.dart';
import '../../services/auth_service.dart';

import 'downloaded_albums_screen.dart';

// Định nghĩa enum cho các loại mục
enum LibraryItemType {
  music,
  artist,
  album,
  downloaded,
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final AuthService _authService = AuthService();
  LibraryItemType _currentType = LibraryItemType.music;
  
  @override
  void initState() {
    super.initState();
    // Add any initialization if needed
  }

  // Handle tab changes, directly navigate to downloaded albums when download tab is selected
  void _handleTabChange(LibraryItemType newType) {
    setState(() {
      _currentType = newType;
    });
    
    // If the "Downloads" tab is selected, navigate to the downloaded albums screen
    if (newType == LibraryItemType.downloaded) {
      // Use a small delay to allow the state to update first
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DownloadedAlbumsScreen(),
            ),
          ).then((_) {
            // When returning from downloaded albums screen, switch back to music tab
            // to avoid immediate re-navigation
            if (mounted && _currentType == LibraryItemType.downloaded) {
              setState(() {
                _currentType = LibraryItemType.music;
              });
            }
          });
        }
      });
    }
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.spotifyBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.spotifyWhite),
                title: const Text(
                  'Hồ sơ',
                  style: TextStyle(color: AppColors.spotifyWhite),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement navigate to profile
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppColors.spotifyWhite),
                title: const Text(
                  'Cài đặt',
                  style: TextStyle(color: AppColors.spotifyWhite),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement navigate to settings
                },
              ),
              const Divider(color: AppColors.spotifyGrey),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.spotifyWhite),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.spotifyWhite),
                ),                onTap: () async {
                  try {
                    Navigator.of(context).pop();
                    await _authService.signOut(context);
                    // Việc điều hướng về màn hình đăng nhập sẽ được xử lý bởi AuthWrapper trong main.dart
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xảy ra lỗi khi đăng xuất: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dữ liệu mẫu cho các mục nhạc - đồng bộ từ Radio phổ biến
  final List<Map<String, String>> _musicItems = [
    {
      'id': 'playlist_thinh_suy',
      'title': 'Với Thịnh Suy, Da LAB, Chillies và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/vu.png',
    },
    {
      'id': 'playlist_hieuthuhai',
      'title': 'Với HIEUTHUHAI, Ronboogz, MANBO và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/bray.png',
    },
    {
      'id': 'playlist_tlinh',
      'title': 'Với tlinh, RPT MCK, Wxrdie và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/low.png',
    },
    {
      'id': 'playlist_mck',
      'title': 'Với RPT MCK, Wren Evans, GREY D và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/tli.png',
    },
    {
      'id': 'playlist_soobin',
      'title': 'Với SOOBIN, HIEUTHUHAI, JustaTee và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/st.png',
    },
    {
      'id': 'playlist_anh_tuan',
      'title': 'Với Bùi Anh Tuấn, Vũ., Noo Phước Thịnh và nhiều hơn nữa',
      'description': 'Playlist • Spotify',
      'imageAsset': 'assets/images/ha.png',
    },
  ];

  // Dữ liệu mẫu cho các nghệ sĩ - đồng bộ từ Nghệ sĩ nổi bật
  final List<Map<String, String>> _artistItems = [
    {
      'id': 'artist_vu',
      'title': 'Vũ',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/vf.png',
    },
    {
      'id': 'artist_den_vau',
      'title': 'Đen Vâu',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/den.png',
    },
    {
      'id': 'artist_bray',
      'title': 'Bray',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/br.png',
    },
    {
      'id': 'artist_hieuthuhai',
      'title': 'Hieuthuhai',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/h2.png',
    },
    {
      'id': 'artist_tlinh',
      'title': 'Tlinh',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/t.png',
    },
    {
      'id': 'artist_amee',
      'title': 'Amee',
      'description': 'Nghệ sĩ',
      'imageAsset': 'assets/images/ame.png',
    },
  ];

  // Dữ liệu mẫu cho các album - đồng bộ từ Album và đĩa nổi tiếng
  final List<Map<String, String>> _albumItems = [
    {
      'id': 'album_rosie',
      'title': 'Rosie',
      'description': 'Album • Coldplay, Maroon 5, Imagine Dragons',
      'imageAsset': 'assets/images/rosie.png',
    },
    {
      'id': 'album_discover_weekly',
      'title': 'Discover Weekly',
      'description': 'Album • Your weekly mixtape of fresh music',
      'imageAsset': 'assets/images/dd.png',
    },
    {
      'id': 'album_jumping_machine',
      'title': 'Jumping machine',
      'description': 'Album • New music from artists you follow',
      'imageAsset': 'assets/images/JP.png',
    },
    {
      'id': 'album_bao_tang',
      'title': 'Bảo Tàng Của Nuối Tiếc',
      'description': 'Album • New music from artists you follow',
      'imageAsset': 'assets/images/tn.png',
    },
  ];

  // Danh sách dummy cho các mục đã tải xuống
  final List<Map<String, String>> _downloadedItems = [
    {
      'id': 'downloads_folder',
      'title': 'Nhạc đã tải',
      'description': 'Playlist • Offline',
      'imageAsset': 'assets/icons/f.png',
    },
  ];

  // Hàm lấy danh sách dựa trên loại
  List<Map<String, String>> _getCurrentItems() {
    switch (_currentType) {
      case LibraryItemType.music:
        return _musicItems;
      case LibraryItemType.artist:
        return _artistItems;
      case LibraryItemType.album:
        return _albumItems;
      case LibraryItemType.downloaded:
        return _downloadedItems;
      }
  }

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
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => _showUserMenu(context),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.orange,
                    child: Text(
                      'U',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Library',
                  style: AppTextStyles.heading.copyWith(fontSize: 22),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.spotifyWhite),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.spotifyWhite),
                onPressed: () {},
              ),
            ],
          ),

          // Filter chips
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text('Nhạc'),
                      selected: _currentType == LibraryItemType.music,
                      onSelected: (selected) {
                        if (selected) {
                          _handleTabChange(LibraryItemType.music);
                        }
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: AppColors.spotifyWhite,
                      labelStyle: TextStyle(
                        color: _currentType == LibraryItemType.music
                            ? AppColors.spotifyBlack
                            : AppColors.spotifyWhite,
                        fontWeight: _currentType == LibraryItemType.music
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Nghệ Sĩ'),
                      selected: _currentType == LibraryItemType.artist,
                      onSelected: (selected) {
                        if (selected) {
                          _handleTabChange(LibraryItemType.artist);
                        }
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: AppColors.spotifyWhite,
                      labelStyle: TextStyle(
                        color: _currentType == LibraryItemType.artist
                            ? AppColors.spotifyBlack
                            : AppColors.spotifyWhite,
                        fontWeight: _currentType == LibraryItemType.artist
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Albums'),
                      selected: _currentType == LibraryItemType.album,
                      onSelected: (selected) {
                        if (selected) {
                          _handleTabChange(LibraryItemType.album);
                        }
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: AppColors.spotifyWhite,
                      labelStyle: TextStyle(
                        color: _currentType == LibraryItemType.album
                            ? AppColors.spotifyBlack
                            : AppColors.spotifyWhite,
                        fontWeight: _currentType == LibraryItemType.album
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Tải Xuống'),
                      selected: _currentType == LibraryItemType.downloaded,
                      onSelected: (selected) {
                        if (selected) {
                          _handleTabChange(LibraryItemType.downloaded);
                        }
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      selectedColor: AppColors.spotifyWhite,
                      labelStyle: TextStyle(
                        color: _currentType == LibraryItemType.downloaded
                            ? AppColors.spotifyBlack
                            : AppColors.spotifyWhite,
                        fontWeight: _currentType == LibraryItemType.downloaded
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sort & view options
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sort,
                        color: AppColors.spotifyWhite,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gần đây',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.grid_view,
                    color: AppColors.spotifyWhite,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Conditional display based on selected type
          _currentType == LibraryItemType.artist
              ? _buildArtistGrid()
              : _buildRegularList(),
        ],
      ),
    );
  }

  // Widget hiển thị lưới nghệ sĩ
  Widget _buildArtistGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final artist = _artistItems[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      artist['imageAsset']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  artist['title']!,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artist['description']!,
                  style: AppTextStyles.smallText,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
          childCount: _artistItems.length,
        ),
      ),
    );
  }

  // Widget hiển thị danh sách thông thường (nhạc, albums, tải xuống)
  Widget _buildRegularList() {
    final items = _getCurrentItems();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          
          // Special handling for downloads folder - navigate to downloads screen
          if (item['id'] == 'downloads_folder') {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  item['imageAsset']!,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                item['title']!,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                item['description']!,
                style: AppTextStyles.smallText,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadedAlbumsScreen(),
                  ),
                );
              },
            );
          }
          
          // Regular playlist items
          return PlaylistItem(
            id: item['id']!,
            title: item['title']!,
            description: item['description']!,
            imageAsset: item['imageAsset']!,
          );
        },
        childCount: items.length,
      ),
    );
  }
}