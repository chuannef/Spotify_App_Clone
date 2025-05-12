import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../services/favorites_service.dart';
import '../services/download_service.dart';
import '../utils/constants.dart';
import 'player_screen.dart';
import 'library/downloaded_albums_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String id; // Added album ID parameter
  final String title;
  final String description;
  final String imageAsset;

  const AlbumDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  bool _isDownloaded = false;

  List<String> _getTrackNames(String albumTitle) {
    if (albumTitle.toLowerCase().contains('bảo tàng của nuối tiếc')) {
      return [
        'Nếu Những Tiếc Nuối',
        'Mùa Mưa Ấy',
        'Ngồi Chờ Trong Vấn Vương - feat. Mỹ Anh',
        'Dành Hết Xuân Thì Để Chờ Nhau - feat. Hà Anh Tuấn',
        'Những Lời Hứa Bỏ Quên - feat. Dear Jane',
        'Bình Yên - feat. Binz'
      ];
    } else if (albumTitle.toLowerCase().contains('show của đen')) {
      return [
        'Mơ (ft. Hậu Vi)',
        'Ngày Lang Thang',
        '10 Triệu Năm',
        'Mười Năm (ft. Ngọc Linh)'
      ];    } else if (albumTitle.toLowerCase().contains('lặng')) {
      return [
        '1000 Ánh Mắt (ft. Obito)',
        'Anh Vẫn Đợi',
        'Có Đôi Điều',
        'Lặng',
        'Night Time'
      ];
    }
    return List.generate(10, (index) => 'Track ${index + 1}');
  }

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  // Check if album is already downloaded
  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await DownloadService.isAlbumDownloaded(widget.id);
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }
  }

  // Handle download/delete of album
  Future<void> _handleDownload(BuildContext context) async {
    if (_isDownloaded) {
      // Show confirmation dialog for deletion
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.spotifyGrey,
          title: Text('Xác nhận xóa', style: AppTextStyles.bodyText),
          content: Text(
            'Bạn có chắc chắn muốn xóa album "${widget.title}" khỏi danh sách tải xuống?',
            style: AppTextStyles.smallText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy', style: TextStyle(color: AppColors.spotifyGreen)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        final deleted = await DownloadService.deleteDownloadedAlbum(widget.id);
        if (mounted) {
          setState(() {
            _isDownloaded = !deleted;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                deleted ? 'Đã xóa khỏi danh sách tải xuống' : 'Không thể xóa album',
              ),
              backgroundColor: deleted ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } else {
      // Download the album
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải xuống...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      final success = await DownloadService.downloadAlbumCover(
        widget.imageAsset,
        widget.id,
        widget.title,
      );
      
      if (mounted) {
        setState(() {
          _isDownloaded = success;
        });
        
        if (success) {
          // Show success dialog with option to view downloaded albums
          final dialogMessage = kIsWeb 
            ? 'Album "${widget.title}" đã được thêm vào danh sách nhạc đã tải. Lưu ý: Trên nền tảng web, các tệp không được tải về thiết bị.'
            : 'Album "${widget.title}" đã được thêm vào danh sách nhạc đã tải. Bạn có thể nghe ngay cả khi không có kết nối mạng.';
            
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.spotifyGrey,
              title: Text('Tải xuống thành công', style: AppTextStyles.bodyText),
              content: Text(
                dialogMessage,
                style: AppTextStyles.smallText,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: AppColors.spotifyGreen)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadedAlbumsScreen(),
                      ),
                    ).then((_) {
                      // Refresh download status when coming back
                      _checkDownloadStatus();
                    });
                  },
                  child: const Text('Xem nhạc đã tải', style: TextStyle(color: AppColors.spotifyGreen)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải xuống thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    final isFavorite = favoritesService.isFavorite(widget.id);

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
                    widget.imageAsset,
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
                          widget.title,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
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
                      // Heart icon - Changes color when favorited
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : AppColors.spotifyLightGrey,
                        ),
                        onPressed: () {
                          favoritesService.toggleFavorite(widget.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite 
                                  ? 'Đã xóa khỏi yêu thích' 
                                  : 'Đã thêm vào yêu thích',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Download icon - Shows different icon when already downloaded
                      IconButton(
                        icon: Icon(
                          _isDownloaded 
                            ? Icons.download_done_outlined 
                            : Icons.file_download_outlined,
                          color: _isDownloaded 
                            ? AppColors.spotifyGreen 
                            : AppColors.spotifyLightGrey,
                        ),
                        onPressed: () => _handleDownload(context),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.spotifyLightGrey,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  // Play button that starts playing from track 1
                  FloatingActionButton(
                    backgroundColor: AppColors.spotifyGreen,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(                          builder: (context) => PlayerScreen(
                            title: 'Nếu Những Tiếc Nuối',
                            imageAsset: widget.imageAsset,
                            currentTrack: 1,
                            totalTracks: _getTrackNames(widget.title).length,
                            albumTitle: widget.title,
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
          SliverList(            delegate: SliverChildBuilderDelegate(
              (context, index) {                // Special handling for albums' tracks
                final trackNames = _getTrackNames(widget.title);
                if (index < trackNames.length) {
                  return ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.spotifyLightGrey,
                      ),
                    ),
                    title: Text(
                      trackNames[index],
                      style: AppTextStyles.bodyText,
                    ),
                    subtitle: Text(
                      index == 0 ? '320K plays' : '280K plays',
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
                            title: 'Track ${index + 1} - ${widget.title}',
                            imageAsset: widget.imageAsset,
                            currentTrack: index + 1,
                            totalTracks: trackNames.length,
                            albumTitle: widget.title,
                          ),
                        ),
                      );
                    },
                  );
                }
                return null;
              },              childCount: _getTrackNames(widget.title).length,
            ),
          ),
        ],
      ),
    );
  }
}