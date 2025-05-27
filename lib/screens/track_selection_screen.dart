import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/music_player_service.dart';
import '../services/favorites_service.dart';
import '../services/download_service.dart';
import '../widgets/app_image.dart';
import 'player_screen.dart';
import 'library/downloaded_albums_screen.dart';

class TrackSelectionScreen extends StatefulWidget {
  final String albumId;
  final String albumTitle;
  final String albumDescription;
  final String imageAsset;

  const TrackSelectionScreen({
    Key? key,
    required this.albumId,
    required this.albumTitle,
    required this.albumDescription,
    required this.imageAsset,
  }) : super(key: key);

  @override
  State<TrackSelectionScreen> createState() => _TrackSelectionScreenState();
}

class _TrackSelectionScreenState extends State<TrackSelectionScreen> {
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  // Check if album is already downloaded
  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await DownloadService.isAlbumDownloaded(widget.albumId);
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
            'Bạn có chắc chắn muốn xóa album "${widget.albumTitle}" khỏi danh sách tải xuống?',
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
        final deleted = await DownloadService.deleteDownloadedAlbum(widget.albumId);
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
        widget.albumId,
        widget.albumTitle,
      );
      
      if (mounted) {
        setState(() {
          _isDownloaded = success;
        });
        
        if (success) {
          // Show success dialog with option to view downloaded albums
          final dialogMessage = kIsWeb 
            ? 'Album "${widget.albumTitle}" đã được thêm vào danh sách nhạc đã tải. Lưu ý: Trên nền tảng web, các tệp không được tải về thiết bị.'
            : 'Album "${widget.albumTitle}" đã được thêm vào danh sách nhạc đã tải. Bạn có thể nghe ngay cả khi không có kết nối mạng.';
            
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

  List<String> _getTrackNames() {
    if (widget.albumTitle.toLowerCase().contains('phép màu')) {
      return [
        'Phép Màu (Đàn Cá Gỗ OST)'
      ];
    } else if (widget.albumTitle.toLowerCase().contains('jumping machine')) {
      return [
        'Jumping Machine'
      ];
    }
    return ['Track 1']; // Fallback
  }
  @override
  Widget build(BuildContext context) {
    final trackList = _getTrackNames();
    final favoritesService = Provider.of<FavoritesService>(context);
    final isFavorite = favoritesService.isFavorite(widget.albumId);

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
                  AppImage(
                    imageAsset: widget.imageAsset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                          widget.albumTitle,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.albumDescription,
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
                          favoritesService.toggleFavorite(widget.albumId);
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
                  // Play all button
                  FloatingActionButton(
                    backgroundColor: AppColors.spotifyGreen,
                    onPressed: () {
                      // Play the first track
                      _playTrack(context, 0);
                    },
                    mini: false,
                    child: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          ),

          // Title section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Chọn bài hát",
                style: AppTextStyles.heading.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),          // Track list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < trackList.length) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.spotifyGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      trackList[index],
                      style: AppTextStyles.bodyText,
                    ),
                    subtitle: Text(
                      widget.albumTitle,
                      style: AppTextStyles.smallText,
                    ),
                    trailing: const Icon(
                      Icons.play_circle_filled,
                      color: AppColors.spotifyGreen,
                      size: 40,
                    ),
                    onTap: () {
                      _playTrack(context, index);
                    },
                  );
                }
                return null;
              },
              childCount: trackList.length,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to play a track
  void _playTrack(BuildContext context, int index) {
    final trackList = _getTrackNames();
    
    // Get the music service
    final musicService = Provider.of<MusicPlayerService>(context, listen: false);
    
    // Play the selected track
    musicService.playTrack(CurrentTrack(
      title: trackList[index],
      albumTitle: widget.albumTitle,
      imageAsset: widget.imageAsset,
      trackNumber: index + 1,
      totalTracks: trackList.length,
    ));
    
    // Navigate to player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          title: trackList[index],
          imageAsset: widget.imageAsset,
          currentTrack: index + 1,
          totalTracks: trackList.length,
          albumTitle: widget.albumTitle,
        ),
      ),
    );
  }
}
