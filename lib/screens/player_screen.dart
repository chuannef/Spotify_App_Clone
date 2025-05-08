import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String imageAsset;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.imageAsset,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = true;
  double _currentSliderValue = 20;

  @override
  void initState() {
    super.initState();
    // Tạo controller cho hiệu ứng đĩa quay
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tính toán kích thước các phần tử
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDiscSize = screenSize.width * 0.7; // Đĩa nhạc chiếm tối đa 70% chiều rộng màn hình

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
              widget.title.split(' - ').last,
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
      // Sử dụng SafeArea để tránh các khu vực như notch trên smartphone
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Phần đĩa quay - chiếm không gian cố định dựa trên kích thước màn hình
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
              
              // Phần thông tin bài hát và điều khiển - sử dụng SingleChildScrollView để tránh overflow
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                    children: [
                      const SizedBox(height: 20), // Giảm padding từ 32 xuống 20
                      Text(
                        widget.title.split(' - ').first,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 22, // Giảm font size từ 24 xuống 22
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Artist Name',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.spotifyLightGrey,
                        ),
                      ),
                      
                      // Thanh tiến trình
                      const SizedBox(height: 20), // Giảm padding
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
                          value: _currentSliderValue,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                          },
                        ),
                      ),
                      
                      // Thời gian
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0:${_currentSliderValue ~/ 5}',
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.spotifyLightGrey,
                              ),
                            ),
                            Text(
                              '3:45',
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.spotifyLightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Nút điều khiển
                      const SizedBox(height: 16), // Giảm padding từ 24 xuống 16
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
                            constraints: const BoxConstraints(), // Giảm padding của buttons
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: AppColors.spotifyWhite,
                              size: 36,
                            ),
                            onPressed: () {},
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
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.repeat,
                              color: AppColors.spotifyLightGrey,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(), // Giảm padding của buttons
                          ),
                        ],
                      ),
                      
                      // Các tùy chọn phát
                      const SizedBox(height: 12), // Giảm padding từ 16 xuống 12
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.devices,
                              color: AppColors.spotifyLightGrey,
                              size: 20, // Giảm kích thước icon
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: AppColors.spotifyLightGrey,
                              size: 20, // Giảm kích thước icon
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.queue_music,
                              color: AppColors.spotifyLightGrey,
                              size: 20, // Giảm kích thước icon
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Padding dưới cùng
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