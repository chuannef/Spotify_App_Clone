import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_player_service.dart';
import '../utils/constants.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String imageAsset;
  final int? currentTrack;
  final int? totalTracks;
  final String albumTitle;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.imageAsset,
    this.currentTrack,
    this.totalTracks,
    required this.albumTitle,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late MusicPlayerService _musicService;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Delayed initialization to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayerWithService();
    });
  }
  
  void _initializePlayerWithService() {
    _musicService = Provider.of<MusicPlayerService>(context, listen: false);
    
    // If we're coming into this screen and there's no current track or it's different from what we want to play,
    // update the service with this track
    if (_musicService.currentTrack == null || 
        widget.currentTrack != _musicService.currentTrack!.trackNumber || 
        widget.albumTitle != _musicService.currentTrack!.albumTitle) {
      
      _musicService.playTrack(CurrentTrack(
        title: widget.title,
        albumTitle: widget.albumTitle,
        imageAsset: widget.imageAsset,
        trackNumber: widget.currentTrack,
        totalTracks: widget.totalTracks,
      ));
    }
    
    // Start rotating animation if music is playing
    if (_musicService.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  String _getTrackName(int trackNumber) {
    if (widget.albumTitle.toLowerCase().contains('bảo tàng của nuối tiếc')) {
      final trackNames = [
        'Nếu Những Tiếc Nuối',
        'Mùa Mưa Ấy',
        'Ngồi Chờ Trong Vấn Vương - feat. Mỹ Anh',
        'Dành Hết Xuân Thì Để Chờ Nhau - feat. Hà Anh Tuấn',
        'Những Lời Hứa Bỏ Quên - feat. Dear Jane',
        'Bình Yên - feat. Binz'
      ];
      return trackNumber > 0 && trackNumber <= trackNames.length ? trackNames[trackNumber - 1] : 'Unknown Track';
    } else if (widget.albumTitle.toLowerCase().contains('show của đen')) {
      final trackNames = [
        'Mơ (ft. Hậu Vi)',
        'Ngày Lang Thang',
        '10 Triệu Năm',
        'Mười Năm (ft. Ngọc Linh)'
      ];
      return trackNumber > 0 && trackNumber <= trackNames.length ? trackNames[trackNumber - 1] : 'Unknown Track';
    } else if (widget.albumTitle.toLowerCase().contains('lặng')) {
      final trackNames = [
        '1000 Ánh Mắt (ft. Obito)',
        'Anh Vẫn Đợi',
        'Có Đôi Điều',
        'Lặng',
        'Night Time'
      ];
      return trackNumber > 0 && trackNumber <= trackNames.length ? trackNames[trackNumber - 1] : 'Unknown Track';
    }
    return widget.title;
  }

  void _playNextTrack() {
    if (widget.currentTrack != null && 
        widget.totalTracks != null && 
        widget.currentTrack! < widget.totalTracks!) {
      
      // Play the next track through the music service
      _musicService.playTrack(CurrentTrack(
        title: _getTrackName(widget.currentTrack! + 1),
        albumTitle: widget.albumTitle,
        imageAsset: widget.imageAsset,
        trackNumber: widget.currentTrack! + 1,
        totalTracks: widget.totalTracks,
      ));
      
      // Navigate to the next track's player screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            title: _getTrackName(widget.currentTrack! + 1),
            imageAsset: widget.imageAsset,
            currentTrack: widget.currentTrack! + 1,
            totalTracks: widget.totalTracks,
            albumTitle: widget.albumTitle,
          ),
        ),
      );
    }
  }

  void _playPreviousTrack() {
    if (widget.currentTrack != null && widget.currentTrack! > 1) {
      // Play the previous track through the music service
      _musicService.playTrack(CurrentTrack(
        title: _getTrackName(widget.currentTrack! - 1),
        albumTitle: widget.albumTitle,
        imageAsset: widget.imageAsset,
        trackNumber: widget.currentTrack! - 1,
        totalTracks: widget.totalTracks,
      ));
      
      // Navigate to the previous track's player screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            title: _getTrackName(widget.currentTrack! - 1),
            imageAsset: widget.imageAsset,
            currentTrack: widget.currentTrack! - 1,
            totalTracks: widget.totalTracks,
            albumTitle: widget.albumTitle,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the music service for changes
    final musicService = Provider.of<MusicPlayerService>(context);
    
    // Update disc rotation based on play state
    if (musicService.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!musicService.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
      final Size screenSize = MediaQuery.of(context).size;
    final double maxDiscSize = screenSize.width * 0.7;
    
    // Ensure we have valid values for slider calculation
    double sliderValue = 0.0;
    if (musicService.duration.inMilliseconds > 0 && 
        musicService.position.inMilliseconds <= musicService.duration.inMilliseconds) {
      sliderValue = musicService.position.inMilliseconds / musicService.duration.inMilliseconds;
    }

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            // Simply show mini player and go back
            musicService.displayMiniPlayer();
            Navigator.pop(context);
          },
        ),
        title: Column(
          children: [
            const Text(
              'PLAYING FROM ALBUM',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.spotifyLightGrey,
              ),
            ),
            Text(
              widget.albumTitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.spotifyWhite,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(
                height: maxDiscSize,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          width: maxDiscSize,
                          height: maxDiscSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.spotifyGrey,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(maxDiscSize),
                            child: Image.asset(
                              widget.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.spotifyGrey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color: AppColors.spotifyWhite,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        widget.currentTrack != null ? _getTrackName(widget.currentTrack!) : widget.title.split(' - ').first,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.albumTitle,
                        style: const TextStyle(
                          color: AppColors.spotifyLightGrey,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderThemeData(
                          thumbColor: AppColors.spotifyWhite,
                          activeTrackColor: AppColors.spotifyWhite,
                          inactiveTrackColor: AppColors.spotifyGrey.withOpacity(0.5),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),                        child: Slider(
                          value: sliderValue.clamp(0.0, 1.0),
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            if (musicService.duration.inMilliseconds > 0) {
                              musicService.seekTo(value);
                            }
                          },
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              musicService.formatDuration(musicService.position),
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.spotifyLightGrey,
                              ),
                            ),
                            Text(
                              musicService.formatDuration(musicService.duration),
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.spotifyLightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shuffle,
                              color: AppColors.spotifyLightGrey,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: AppColors.spotifyWhite,
                              size: 36,
                            ),
                            onPressed: widget.currentTrack != null && widget.currentTrack! > 1 
                                ? _playPreviousTrack 
                                : null,
                          ),
                          FloatingActionButton(
                            backgroundColor: AppColors.spotifyWhite,
                            onPressed: () {
                              musicService.togglePlayPause();
                            },
                            child: Icon(
                              musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: AppColors.spotifyBlack,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: AppColors.spotifyWhite,
                              size: 36,
                            ),
                            onPressed: widget.currentTrack != null && 
                                      widget.totalTracks != null && 
                                      widget.currentTrack! < widget.totalTracks! 
                                ? _playNextTrack 
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.repeat,
                              color: AppColors.spotifyGreen,
                            ),
                            onPressed: () {
                              musicService.restartTrack();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.devices,
                              color: AppColors.spotifyLightGrey,
                              size: 20,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: AppColors.spotifyLightGrey,
                              size: 20,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.queue_music,
                              color: AppColors.spotifyLightGrey,
                              size: 20,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
