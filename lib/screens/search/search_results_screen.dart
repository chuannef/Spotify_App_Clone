import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/music_player_service.dart';
import '../player_screen.dart';
import '../album_detail_screen.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    final query = widget.query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    // Search in "Bảo Tàng Của Nuối Tiếc" album
    final btntTracks = [
      'Nếu Những Tiếc Nuối',
      'Mùa Mưa Ấy',
      'Ngồi Chờ Trong Vấn Vương - feat. Mỹ Anh',
      'Dành Hết Xuân Thì Để Chờ Nhau - feat. Hà Anh Tuấn',
      'Những Lời Hứa Bỏ Quên - feat. Dear Jane',
      'Bình Yên - feat. Binz'
    ];

    for (int i = 0; i < btntTracks.length; i++) {
      if (btntTracks[i].toLowerCase().contains(query)) {
        results.add({
          'title': btntTracks[i],
          'albumTitle': 'Bảo Tàng Của Nuối Tiếc',
          'artist': 'Vũ.',
          'trackNumber': i + 1,
          'totalTracks': btntTracks.length,
          'imageAsset': 'assets/images/vu.png',
        });
      }
    }

    // Search in "Show của Đen" album
    final scdTracks = [
      'Mơ (ft. Hậu Vi)',
      'Ngày Lang Thang',
      '10 Triệu Năm',
      'Mười Năm (ft. Ngọc Linh)'
    ];

    for (int i = 0; i < scdTracks.length; i++) {
      if (scdTracks[i].toLowerCase().contains(query)) {
        results.add({
          'title': scdTracks[i],
          'albumTitle': 'Show của Đen',
          'artist': 'Đen Vâu',
          'trackNumber': i + 1,
          'totalTracks': scdTracks.length,
          'imageAsset': 'assets/images/den.png',
        });
      }
    }

    // Search in "Lặng" album
    final langTracks = [
      '1000 Ánh Mắt (ft. Obito)',
      'Anh Vẫn Đợi',
      'Có Đôi Điều',
      'Lặng',
      'Night Time'
    ];

    for (int i = 0; i < langTracks.length; i++) {
      if (langTracks[i].toLowerCase().contains(query)) {
        results.add({
          'title': langTracks[i],
          'albumTitle': 'Lặng',
          'artist': 'Bray',
          'trackNumber': i + 1,
          'totalTracks': langTracks.length,
          'imageAsset': 'assets/images/bray.png',
        });
      }
    }

    // Search by artist name or album title
    final artistsAndAlbums = {
      'vũ': 'Bảo Tàng Của Nuối Tiếc',
      'đen': 'Show của Đen',
      'bray': 'Lặng',
      'bảo tàng': 'Bảo Tàng Của Nuối Tiếc',
      'nuối tiếc': 'Bảo Tàng Của Nuối Tiếc',
      'show': 'Show của Đen',
      'lặng': 'Lặng',
    };

    artistsAndAlbums.forEach((key, value) {
      if (key.contains(query) || value.toLowerCase().contains(query)) {
        // Add album to search results if not already added
        bool albumAlreadyAdded = false;
        for (final result in results) {
          if (result['albumTitle'] == value && result['isAlbumResult'] == true) {
            albumAlreadyAdded = true;
            break;
          }
        }

        if (!albumAlreadyAdded) {
          List<String> tracks;
          String imageAsset;
          String artist;

          if (value == 'Bảo Tàng Của Nuối Tiếc') {
            tracks = btntTracks;
            imageAsset = 'assets/images/vu.png';
            artist = 'Vũ.';
          } else if (value == 'Show của Đen') {
            tracks = scdTracks;
            imageAsset = 'assets/images/den.png';
            artist = 'Đen Vâu';
          } else {
            tracks = langTracks;
            imageAsset = 'assets/images/bray.png';
            artist = 'Bray';
          }

          results.add({
            'title': value, // Use album title for album results
            'albumTitle': value,
            'artist': artist,
            'trackNumber': 1,
            'totalTracks': tracks.length,
            'imageAsset': imageAsset,
            'isAlbumResult': true,
          });
        }
      }
    });

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: AppColors.spotifyBlack,
        elevation: 0,
        title: Text(
          'Search results for "${widget.query}"',
          style: AppTextStyles.bodyText,
        ),
        iconTheme: const IconThemeData(color: AppColors.spotifyWhite),
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.spotifyGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "${widget.query}"',
                    style: AppTextStyles.subHeading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching again using different keywords',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.spotifyLightGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildSearchResultsView(),
              ],
            ),
    );
  }

  Widget _buildSearchResultsView() {
    // Separate results by type
    final songResults = searchResults.where((result) => result['isAlbumResult'] != true).toList();
    final albumResults = searchResults.where((result) => result['isAlbumResult'] == true).toList();

    return Expanded(
      child: ListView(
        children: [
          // Display album results if available
          if (albumResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'Albums',
                style: TextStyle(
                  color: AppColors.spotifyWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...albumResults.map((result) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  result['imageAsset'],
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                result['albumTitle'],
                style: AppTextStyles.bodyText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                'By ${result['artist']}',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.spotifyLightGrey,
                ),
              ),
              trailing: const Icon(Icons.album, color: AppColors.spotifyGreen),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlbumDetailScreen(
                      id: result['albumTitle'].toLowerCase().replaceAll(' ', '_'),
                      title: result['albumTitle'],
                      description: 'Album by ${result['artist']}',
                      imageAsset: result['imageAsset'],
                    ),
                  ),
                );
              },
            )),
          ],

          // Display song results if available
          if (songResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                'Songs',
                style: TextStyle(
                  color: AppColors.spotifyWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...songResults.map((result) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  result['imageAsset'],
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                result['title'],
                style: AppTextStyles.bodyText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['artist'],
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.spotifyLightGrey,
                    ),
                  ),
                  Text(
                    'Album: ${result['albumTitle']}',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.spotifyLightGrey,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.music_note, color: AppColors.spotifyGreen),
              onTap: () {
                final musicService = Provider.of<MusicPlayerService>(context, listen: false);
                
                // Play the song and open player screen
                musicService.playTrack(CurrentTrack(
                  title: result['title'],
                  albumTitle: result['albumTitle'],
                  imageAsset: result['imageAsset'],
                  trackNumber: result['trackNumber'],
                  totalTracks: result['totalTracks'],
                ));

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      title: result['title'],
                      imageAsset: result['imageAsset'],
                      currentTrack: result['trackNumber'],
                      totalTracks: result['totalTracks'],
                      albumTitle: result['albumTitle'],
                    ),
                  ),
                );
              },
            )),
          ],
        ],
      ),
    );
  }
}
