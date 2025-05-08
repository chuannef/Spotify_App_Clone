import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/constants.dart';
import '../../services/download_service.dart';
import '../album_detail_screen.dart';

class DownloadedAlbumsScreen extends StatefulWidget {
  const DownloadedAlbumsScreen({Key? key}) : super(key: key);

  @override
  State<DownloadedAlbumsScreen> createState() => _DownloadedAlbumsScreenState();
}

class _DownloadedAlbumsScreenState extends State<DownloadedAlbumsScreen> {
  List<Map<String, String>> _downloadedAlbums = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDownloadedAlbums();
  }

  Future<void> _loadDownloadedAlbums() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final albums = await DownloadService.getDownloadedAlbums();

      if (mounted) {
        setState(() {
          _downloadedAlbums = albums;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách album: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAlbum(String albumId, String albumName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.spotifyGrey,
        title: Text('Xác nhận xóa', style: AppTextStyles.bodyText),
        content: Text(
          'Bạn có chắc chắn muốn xóa album "$albumName" khỏi danh sách tải xuống?',
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
      final deleted = await DownloadService.deleteDownloadedAlbum(albumId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deleted ? 'Đã xóa khỏi danh sách tải xuống' : 'Không thể xóa album',
            ),
            backgroundColor: deleted ? Colors.green : Colors.red,
          ),
        );

        // Reload the list if deletion was successful
        if (deleted) {
          await _loadDownloadedAlbums();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: AppColors.spotifyBlack,
        title: const Text('Nhạc đã tải'),
        foregroundColor: AppColors.spotifyWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.spotifyWhite),
            onPressed: () {
              _refreshKey.currentState?.show();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _loadDownloadedAlbums,
        color: AppColors.spotifyGreen,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.spotifyGreen,
                ),
              )
            : _downloadedAlbums.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.download_done_outlined,
                          size: 64,
                          color: AppColors.spotifyLightGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có album nào được tải xuống',
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kIsWeb
                              ? 'Các album được đánh dấu tải xuống sẽ xuất hiện ở đây'
                              : 'Các album bạn tải xuống sẽ xuất hiện ở đây và có thể nghe ngay cả khi không có kết nối mạng',
                          style: AppTextStyles.smallText,
                          textAlign: TextAlign.center,
                        ),
                        if (kIsWeb)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Lưu ý: Trên nền tảng web, các tệp không được tải về thiết bị',
                              style: AppTextStyles.smallText.copyWith(
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.spotifyGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Khám phá nhạc'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: _downloadedAlbums.length,
                    itemBuilder: (context, index) {
                      final album = _downloadedAlbums[index];
                      if (album.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              album['imageAsset']!,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: AppColors.spotifyGrey,
                                  child: const Icon(
                                    Icons.music_note,
                                    color: AppColors.spotifyWhite,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            album['name']!,
                            style: AppTextStyles.bodyText,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(
                                Icons.download_done,
                                size: 14,
                                color: AppColors.spotifyGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                kIsWeb ? 'Đã đánh dấu' : 'Đã tải xuống',
                                style: TextStyle(
                                  color: AppColors.spotifyGreen,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.spotifyLightGrey,
                            ),
                            onPressed: () => _deleteAlbum(album['id']!, album['name']!),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumDetailScreen(
                                  id: album['id']!,
                                  title: album['name']!,
                                  description: 'Album đã tải xuống',
                                  imageAsset: album['imageAsset']!,
                                ),
                              ),
                            ).then((_) => _loadDownloadedAlbums());
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}