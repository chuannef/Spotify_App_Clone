import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  bool _isPlaying = false;
  final audioPlayer = AudioPlayer();
  Duration _duration = const Duration();
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() async {
    // Configure audio session
    await audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Listen to player state changes
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (_isPlaying) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      });
    });

    // Listen to duration changes
    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    // Listen to position changes
    audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    // Listen to player completion
    audioPlayer.onPlayerComplete.listen((_) {
      _onTrackComplete();
    });

    // Auto-play the track when screen opens
    _loadAndPlayTrack();
  }

  void _onTrackComplete() {
    if (widget.currentTrack != null && 
        widget.totalTracks != null && 
        widget.currentTrack! < widget.totalTracks!) {
      _playNextTrack();
    } else {
      setState(() {
        _isPlaying = false;
        _controller.stop();
      });
    }
  }
  Future<void> _loadAndPlayTrack() async {
    try {      
      String audioPath = '';
      
      if (widget.albumTitle.toLowerCase().contains('bảo tàng của nuối tiếc')) {
        audioPath = 'assets/sound/Bảo Tàng Của Nuối Tiếc/Bảo Tàng Của Nuối Tiếc_${widget.currentTrack}.mp3';
      } else if (widget.albumTitle.toLowerCase().contains('show của đen')) {
        final trackFiles = [
          'Đen - Mơ ft. Hậu Vi .mp3',
          'Đen- Ngày Lang Thang.mp3',
          'Đen-10 Triệu Năm.mp3',
          'Đen-Mười-Năm-ft.-Ngọc-Linh-_M_V_-_Lộn-Xộn-3_.mp3'
        ];
        audioPath = 'assets/sound/Show của Đen/${trackFiles[widget.currentTrack! - 1]}';
      } else if (widget.title.toLowerCase().contains('jumping machine')) {
        audioPath = 'assets/sound/Jumping machine.mp3';
      }
        final source = AssetSource(audioPath.replaceFirst('assets/', ''));
      print('Loading audio file: $audioPath'); // Debug print
        
      await audioPlayer.setSource(source);
      await audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
      _controller.repeat();
    } catch (e) {
      print('Error loading audio: $e');
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
    }
    return widget.title;
  }

  void _playNextTrack() {
    if (widget.currentTrack != null && 
        widget.totalTracks != null && 
        widget.currentTrack! < widget.totalTracks!) {
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
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDiscSize = screenSize.width * 0.7;
    final double sliderValue = _duration.inMilliseconds > 0 
        ? _position.inMilliseconds / _duration.inMilliseconds 
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
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
                        ),
                        child: Slider(
                          value: sliderValue.clamp(0.0, 1.0),
                          onChanged: (value) {
                            if (_duration.inMilliseconds > 0) {
                              final position = value * _duration.inMilliseconds;
                              audioPlayer.seek(Duration(milliseconds: position.round()));
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
                              _formatDuration(_position),
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.spotifyLightGrey,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
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
                            onPressed: _togglePlayPause,
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
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
                              color: AppColors.spotifyLightGrey,
                            ),
                            onPressed: () {},
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