import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/library/playlist_item.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart'; // Import FavoritesService
import '../../models/album_model.dart'; // Import Album model
import 'package:provider/provider.dart'; // Import Provider

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
  LibraryItemType _currentType = LibraryItemType.album; // Default to Album tab
  late FavoritesService _favoritesService; // Declare FavoritesService instance
  List<Album> _allAlbums = []; // Placeholder for all albums - REPLACE WITH ACTUAL DATA SOURCE
  List<Map<String, String>> _favoriteAlbumItems = []; // List to hold favorite album data for UI

  @override
  void initState() {
    super.initState();
    _favoritesService = Provider.of<FavoritesService>(context, listen: false);
    _loadAllAlbums(); // Load all albums
    _favoritesService.addListener(_updateFavoriteAlbums); // Listen for changes in favorites
    _updateFavoriteAlbums(); // Initial load of favorite albums
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_updateFavoriteAlbums); // Clean up listener
    super.dispose();
  }

  // Method to simulate loading all albums (replace with actual data fetching)
  void _loadAllAlbums() {
    // This is a placeholder. You should fetch your actual album data here.
    // For example, if you have a list of all albums defined somewhere:
    // _allAlbums = allAlbumsGlobalList; 
    // Or fetch from a service:
    // _allAlbums = await AlbumService.getAllAlbums();

    // For demonstration, using the existing _albumItemsStatic as the source of all albums
    // You'll need to adapt this to your actual Album model structure.
    _allAlbums = _albumItemsStatic.map((item) {
      return Album(
        id: item['id']!,
        name: item['title']!,
        description: item['description']!,
        imageUrl: item['imageAsset']!,
        songs: [], // Assuming songs list might be empty or populated elsewhere
      );
    }).toList();
  }

  void _updateFavoriteAlbums() {
    if (!_favoritesService.isLoaded) {
      debugPrint("[LibraryScreen] Favorites not loaded yet.");
      return;
    }
    final favoriteIds = _favoritesService.favoriteAlbumIds;
    debugPrint("[LibraryScreen] Favorite Album IDs from Service: $favoriteIds");
    debugPrint("[LibraryScreen] All Album IDs in _allAlbums: ${_allAlbums.map((a) => a.id).toList()}");

    final favoriteAlbums = _allAlbums.where((album) => favoriteIds.contains(album.id)).toList();
    debugPrint("[LibraryScreen] Filtered Favorite Albums to display: ${favoriteAlbums.map((a) => a.id).toList()}");

    setState(() {
      _favoriteAlbumItems = favoriteAlbums.map((album) => {
        'id': album.id,
        'title': album.name,
        'description': album.description,
        'imageAsset': album.imageUrl,
      }).toList();
    });
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
  // This list will now be populated by _favoriteAlbumItems when the album tab is active
  // However, we need a source for _allAlbums. Let's keep the static list for that purpose
  static final List<Map<String, String>> _albumItemsStatic = [
    {
      'id': 'album_show_cua_den',
      'title': 'Show của Đen',
      'description': 'Album • Đen Vâu',
      'imageAsset': 'assets/images/den.png', 
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
    {
      'id': 'album_Lặng',
      'title': 'Lặng',
      'description': 'Shiki (@shikidaspirit) is a Vietnamese artist and producer, based in Ho Chi Minh City',
      'imageAsset': 'assets/images/album/lang.png',
    },
    {
      'id': 'album_phep_mau',
      'title': 'Phép Màu',
      'description': 'Phép Màu (Đàn Cá Gỗ Original Soundtrack)',      'imageAsset': 'assets/images/album/pe.png',
    },
    // Add other albums here that can be favorited
  ];

  // Hàm lấy danh sách dựa trên loại
  List<Map<String, String>> _getCurrentItems() {
    switch (_currentType) {
      case LibraryItemType.music:
        return _musicItems;
      case LibraryItemType.artist:
        return _artistItems;
      case LibraryItemType.album:
        return _favoriteAlbumItems; // Return favorite albums when album tab is selected
      case LibraryItemType.downloaded:
        return []; // Return empty list as navigation is handled directly
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
                      'CN',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Thư viện của bạn',
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
    if (_currentType == LibraryItemType.album && !_favoritesService.isLoaded) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.spotifyGreen)),
      );
    }
    if (_currentType == LibraryItemType.album && items.isEmpty && _favoritesService.isLoaded) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Bạn chưa có album yêu thích nào.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.spotifyGrey),
          ),
        ),
      );
    }
    // If current type is downloaded and items are empty (due to direct navigation),
    // this will correctly build an empty list.
    if (_currentType == LibraryItemType.downloaded && items.isEmpty) {
        // Nothing to display here as navigation to DownloadedAlbumsScreen is direct.
        // The SliverList below will handle items.length == 0 correctly.
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          
          // The special handling for 'downloads_folder' is removed
          // as _getCurrentItems() returns an empty list for LibraryItemType.downloaded,
          // and navigation is handled by _handleTabChange.
          
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