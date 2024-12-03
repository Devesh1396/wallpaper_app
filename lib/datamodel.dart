import 'package:cloud_firestore/cloud_firestore.dart';

class Wallpaper {
  String? id;
  String userId;
  String imageUrl;
  DateTime timestamp;

  Wallpaper({
    this.id,
    required this.userId,
    required this.imageUrl,
    required this.timestamp,
  });

  factory Wallpaper.fromFirestore(Map<String, dynamic> json, String id) {
    return Wallpaper(
      id: id,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
