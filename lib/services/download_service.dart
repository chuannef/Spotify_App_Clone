import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadService {
  static const String _downloadListKey = 'downloaded_albums';

  // Download an album cover and save to gallery
  static Future<bool> downloadAlbumCover(String imageAsset, String albumId, String albumName) async {
    try {
      // For web platform, we can't access the file system or request permissions
      // Just record the download in SharedPreferences
      if (kIsWeb) {
        await _addToDownloadList(albumId, albumName, imageAsset);
        debugPrint('Web platform - recording download without saving file');
        return true;
      }
      
      // Mobile platforms continue with normal download process
      // Request storage permission
      if (!await _requestPermission()) {
        debugPrint('Storage permission denied');
        return false;
      }
      
      // Get temporary directory to store the download first
      final directory = await getTemporaryDirectory();
      final fileName = '${albumName.replaceAll(' ', '_')}_cover.jpg';
      final filePath = '${directory.path}/$fileName';
      
      // Try loading from assets
      try {
        ByteData data = await rootBundle.load(imageAsset);
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        
        // Write to temporary file
        await File(filePath).writeAsBytes(bytes);
        
        // Save to gallery
        final result = await GallerySaver.saveImage(
          filePath,
          albumName: 'Downloaded Albums',
        );
        
        if (result == true) {
          // Record the download in SharedPreferences
          await _addToDownloadList(albumId, albumName, imageAsset);
          return true;
        }
        debugPrint('Gallery saver failed');
        return false;
      } catch (e) {
        debugPrint('Error loading asset: $e');
        
        // If asset loading fails, try with http request if it's a URL
        if (imageAsset.startsWith('http')) {
          final response = await http.get(Uri.parse(imageAsset));
          
          if (response.statusCode == 200) {
            // Save file to temporary storage
            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            
            // Save to gallery
            final result = await GallerySaver.saveImage(
              filePath,
              albumName: 'Downloaded Albums',
            );
            
            if (result == true) {
              // Record the download in SharedPreferences
              await _addToDownloadList(albumId, albumName, imageAsset);
              return true;
            }
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('Download error: $e');
      return false;
    }
  }

  // Request storage permission
  static Future<bool> _requestPermission() async {
    if (kIsWeb) {
      // Web doesn't support storage permissions
      return true;
    }
    
    PermissionStatus status = await Permission.storage.status;
    
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    
    return status.isGranted;
  }
  
  // Add album to downloaded list
  static Future<void> _addToDownloadList(String albumId, String albumName, String imageAsset) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadList = prefs.getStringList(_downloadListKey) ?? [];
    
    // Store as JSON-like string: "albumId:::albumName:::imageAsset"
    final albumData = '$albumId:::$albumName:::$imageAsset';
    
    if (!downloadList.contains(albumData)) {
      downloadList.add(albumData);
      await prefs.setStringList(_downloadListKey, downloadList);
    }
  }

  // Get list of downloaded albums
  static Future<List<Map<String, String>>> getDownloadedAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadList = prefs.getStringList(_downloadListKey) ?? [];
    
    // Parse the stored strings back into maps
    return downloadList.map((albumData) {
      final parts = albumData.split(':::');
      if (parts.length == 3) {
        return {
          'id': parts[0],
          'name': parts[1],
          'imageAsset': parts[2],
        };
      }
      return <String, String>{};
    }).toList();
  }

  // Delete downloaded album
  static Future<bool> deleteDownloadedAlbum(String albumId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadList = prefs.getStringList(_downloadListKey) ?? [];
      
      // Find and remove the album with matching ID
      final filteredList = downloadList.where((item) {
        return !item.startsWith('$albumId:::');
      }).toList();
      
      // Save the updated list back to preferences
      await prefs.setStringList(_downloadListKey, filteredList);
      
      // Note: We're not deleting the actual file from gallery since that would
      // require more complex gallery manipulation that might not be allowed by OS
      // We're just removing it from our app's record
      
      return true;
    } catch (e) {
      debugPrint('Delete download error: $e');
      return false;
    }
  }

  // Check if album is downloaded
  static Future<bool> isAlbumDownloaded(String albumId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadList = prefs.getStringList(_downloadListKey) ?? [];
    
    return downloadList.any((item) => item.startsWith('$albumId:::'));
  }
}