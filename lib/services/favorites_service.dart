import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> _favoriteAlbumIds = {};
  bool _isLoaded = false;
  User? _currentUser;

  FavoritesService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _loadFavorites();
    } else {
      _isLoaded = true; // Mark as loaded even if no user, to prevent indefinite loading
      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user) {
    if (user != null && user.uid != _currentUser?.uid) {
      _currentUser = user;
      _favoriteAlbumIds.clear(); // Clear previous user's favorites
      _isLoaded = false; // Reset loaded state for new user
      notifyListeners(); // Notify listeners about the change (e.g. to show loading)
      _loadFavorites();
    } else if (user == null) {
      _currentUser = null;
      _favoriteAlbumIds.clear();
      _isLoaded = true; // No user, so "loaded" (empty)
      notifyListeners();
    }
  }

  // Check if album is favorited
  bool isFavorite(String albumId) {
    return _favoriteAlbumIds.contains(albumId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String albumId) async {
    if (_currentUser == null) {
      debugPrint("User not logged in. Cannot toggle favorite.");
      // Optionally, prompt user to log in
      return;
    }

    if (_favoriteAlbumIds.contains(albumId)) {
      _favoriteAlbumIds.remove(albumId);
    } else {
      _favoriteAlbumIds.add(albumId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  // Load favorites from Firestore
  Future<void> _loadFavorites() async {
    if (_currentUser == null) {
      _isLoaded = true;
      notifyListeners();
      return;
    }
    try {
      final docRef = _firestore.collection('users').doc(_currentUser!.uid).collection('favorites').doc('albums');
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('albumIds') && data['albumIds'] is List) {
          _favoriteAlbumIds = Set<String>.from(data['albumIds']);
        } else {
          _favoriteAlbumIds = {}; // Ensure it's initialized if field is missing or wrong type
        }
      } else {
        _favoriteAlbumIds = {}; // No favorites document yet, or it's empty
      }
      _isLoaded = true;
      notifyListeners();
      debugPrint("[FavoritesService] Loaded favorites for user ${_currentUser!.uid}: $_favoriteAlbumIds");
    } catch (e) {
      debugPrint('Error loading favorites from Firestore: $e');
      _isLoaded = true; // Still mark as loaded to avoid blocking UI
      _favoriteAlbumIds = {}; // Reset on error
      notifyListeners();
    }
  }

  // Save favorites to Firestore
  Future<void> _saveFavorites() async {
    if (_currentUser == null) return;

    try {
      final docRef = _firestore.collection('users').doc(_currentUser!.uid).collection('favorites').doc('albums');
      await docRef.set({
        'albumIds': _favoriteAlbumIds.toList(),
      });
      debugPrint("[FavoritesService] Saved favorites for user ${_currentUser!.uid}: $_favoriteAlbumIds");
    } catch (e) {
      debugPrint('Error saving favorites to Firestore: $e');
    }
  }

  // Get all favorite album IDs
  List<String> get favoriteAlbumIds => _favoriteAlbumIds.toList();
  
  // Check if data is loaded
  bool get isLoaded => _isLoaded;

  // Optional: Method to manually refresh favorites if needed
  Future<void> refreshFavorites() async {
    if (_currentUser != null) {
      _isLoaded = false;
      notifyListeners(); // Show loading indicator
      await _loadFavorites();
    }
  }
}