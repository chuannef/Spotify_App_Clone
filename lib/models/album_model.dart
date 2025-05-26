class Album {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Song> songs; // Assuming you have a Song model

  Album({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.songs,
  });

  // If you need to convert from/to JSON, you can add factory constructors
  // and toJson methods here. For example:
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      songs: (json['songs'] as List<dynamic>? ?? [])
          .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }
}

// Placeholder for Song model - you should have this defined elsewhere
class Song {
  final String id;
  final String title;
  final String artist;
  final String url; // URL of the song
  final String coverImageUrl; // URL of the cover image

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.coverImageUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'coverImageUrl': coverImageUrl,
    };
  }
}
