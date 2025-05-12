import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../services/music_player_service.dart';
import '../utils/constants.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicService = Provider.of<MusicPlayerService>(context);
    final currentTrack = musicService.currentTrack;
    
    // Don't show if there's no track or mini player is hidden
    if (currentTrack == null || !musicService.showMiniPlayer) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              title: currentTrack.title,
              imageAsset: currentTrack.imageAsset,
              currentTrack: currentTrack.trackNumber,
              totalTracks: currentTrack.totalTracks,
              albumTitle: currentTrack.albumTitle,
            ),
          ),
        );
      },
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.spotifyGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Album art
            Container(
              width: 56,
              height: 56,
              margin: const EdgeInsets.all(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        currentTrack.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.spotifyGrey,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.spotifyWhite,
                            ),
                          );
                        },
                      ),
                      if (musicService.isPlaying)
                        AnimatedBuilder(
                          animation: const AlwaysStoppedAnimation(0),
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: math.pi / 8, // Small rotation for effect
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.spotifyGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.spotifyBlack,
                                  size: 10,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTrack.title,
                    style: const TextStyle(
                      color: AppColors.spotifyWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentTrack.albumTitle,
                    style: TextStyle(
                      color: AppColors.spotifyWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4),
                    child: LinearProgressIndicator(
                      value: musicService.duration.inMilliseconds > 0 
                          ? musicService.position.inMilliseconds / musicService.duration.inMilliseconds 
                          : 0.0,
                      backgroundColor: AppColors.spotifyLightGrey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spotifyGreen),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),            
            // Play/Pause button
            IconButton(
              icon: Icon(
                musicService.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.spotifyWhite,
              ),
              onPressed: () {
                musicService.togglePlayPause();
              },
            ),
              // Close (X) button to hide mini player and stop music
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.spotifyWhite,
                size: 20,
              ),
              onPressed: () {
                // Stop the music and hide the mini player
                musicService.stopMusic();
                musicService.hideMiniPlayer();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            SizedBox(width: 8), // Add some padding on the right side
          ],
        ),
      ),
    );
  }
}
