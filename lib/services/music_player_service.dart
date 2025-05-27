import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CurrentTrack {
  final String title;
  final String albumTitle;
  final String imageAsset;
  final int? trackNumber;
  final int? totalTracks;

  CurrentTrack({
    required this.title,
    required this.albumTitle,
    required this.imageAsset,
    this.trackNumber,
    this.totalTracks,
  });
}

class MusicPlayerService with ChangeNotifier {
  final audioPlayer = AudioPlayer();
  
  // Player state
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  
  // Track information
  CurrentTrack? _currentTrack;
  CurrentTrack? get currentTrack => _currentTrack;
  
  // Track durations
  Duration _duration = const Duration();
  Duration get duration => _duration;
  
  Duration _position = const Duration();
  Duration get position => _position;
  
  // Show/hide the mini player
  bool _showMiniPlayer = false;
  bool get showMiniPlayer => _showMiniPlayer;
  
  // Subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completionSubscription;
  
  MusicPlayerService() {
    _initAudioPlayer();
  }
  
  void _initAudioPlayer() async {
    await audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Listen to player state changes
    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = audioPlayer.onDurationChanged.listen((Duration d) {
      _duration = d;
      notifyListeners();
    });

    // Listen to position changes
    _positionSubscription = audioPlayer.onPositionChanged.listen((Duration p) {
      _position = p;
      notifyListeners();
    });

    // Listen to player completion
    _completionSubscription = audioPlayer.onPlayerComplete.listen((_) {
      _onTrackComplete();
    });
  }
  
  void _onTrackComplete() {
    if (_currentTrack != null && 
        _currentTrack!.trackNumber != null && 
        _currentTrack!.totalTracks != null && 
        _currentTrack!.trackNumber! < _currentTrack!.totalTracks!) {
      // Could implement auto next here
      // For now just stop player
      _isPlaying = false;
    } else {
      _isPlaying = false;
    }
    notifyListeners();
  }
    Future<void> playTrack(CurrentTrack track) async {
    // First stop any currently playing track
    await audioPlayer.stop();
    
    _currentTrack = track;
    _showMiniPlayer = true;
    
    try {
      String audioPath = '';
      
      if (track.albumTitle.toLowerCase().contains('bảo tàng của nuối tiếc')) {
        audioPath = 'assets/sound/Bảo Tàng Của Nuối Tiếc/Bảo Tàng Của Nuối Tiếc_${track.trackNumber}.mp3';
      } else if (track.albumTitle.toLowerCase().contains('show của đen')) {
        final trackFiles = [
          'Đen - Mơ ft. Hậu Vi .mp3',
          'Đen- Ngày Lang Thang.mp3',
          'Đen-10 Triệu Năm.mp3',
          'Đen-Mười-Năm-ft.-Ngọc-Linh-_M_V_-_Lộn-Xộn-3_.mp3'
        ];
        audioPath = 'assets/sound/Show của Đen/${trackFiles[track.trackNumber! - 1]}';
      } else if (track.albumTitle.toLowerCase().contains('phép màu')) {
        // Added specific handling for Phép Màu album
        audioPath = 'assets/sound/phepmau.mp3';
      } else if (track.albumTitle.toLowerCase().contains('lặng')) {
        final trackFiles = [
          '1000 Ánh Mắt (ft. Obito).mp3',
          'Anh Vẫn Đợi.mp3',
          'Có Đôi Điều .mp3', 
          'Lặng.mp3',
          'Night Time.mp3'
        ];
        int index = (track.trackNumber! - 1) % trackFiles.length;
        audioPath = 'assets/sound/Lặng/${trackFiles[index]}';      } else if (track.albumTitle.toLowerCase().contains('jumping machine') || 
                 track.title.toLowerCase().contains('jumping machine')) {
        audioPath = 'assets/sound/Jumping machine.mp3';
      }
      
      // Set source and play
      await audioPlayer.setSource(AssetSource(audioPath.replaceFirst('assets/', '')));
      await audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
      
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }
  
  // Playback control methods
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
    notifyListeners();
  }
  
  Future<void> restartTrack() async {
    try {
      await audioPlayer.seek(const Duration(seconds: 0));
      if (!_isPlaying) {
        await audioPlayer.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error restarting track: $e');
    }
  }
    Future<void> seekTo(double position) async {
    if (_duration.inMilliseconds > 0) {
      try {
        // Ensure position is between 0.0 and 1.0
        position = position.clamp(0.0, 1.0);
        final newPosition = (position * _duration.inMilliseconds).toInt();
        await audioPlayer.seek(Duration(milliseconds: newPosition));
        notifyListeners();
      } catch (e) {
        print('Error in seekTo: $e');
      }
    }
  }
  
  void displayMiniPlayer() {
    _showMiniPlayer = true;
    notifyListeners();
  }
  
  void hideMiniPlayer() {
    _showMiniPlayer = false;
    notifyListeners();
  }
  
  // Stop music playback completely
  Future<void> stopMusic() async {
    try {
      await audioPlayer.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      print('Error stopping music: $e');
    }
  }
  
  // Format duration to display in UI
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completionSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
