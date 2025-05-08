import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_albums';
  Set<String> _favoriteAlbumIds = {};
  bool _isLoaded = false;

  FavoritesService() {
    _loadFavorites();
  }

  // Check if album is favorited
  bool isFavorite(String albumId) {
    return _favoriteAlbumIds.contains(albumId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String albumId) async {
    if (_favoriteAlbumIds.contains(albumId)) {
      _favoriteAlbumIds.remove(albumId);
    } else {
      _favoriteAlbumIds.add(albumId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteAlbumIds = Set<String>.from(favorites);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteAlbumIds.toList());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Get all favorite album IDs
  List<String> get favoriteAlbumIds => _favoriteAlbumIds.toList();
  
  // Check if data is loaded
  bool get isLoaded => _isLoaded;
}