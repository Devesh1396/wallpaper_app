import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/datamodel.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveWallpaper(Wallpaper wallpaper) async {
    try {
      await _firestore.collection('user_wallpapers').add(wallpaper.toFirestore());
      debugPrint('Wallpaper saved successfully.');
    } catch (e) {
      debugPrint('Error saving wallpaper: $e');
    }
  }

  Stream<List<Wallpaper>> getWallpapersForUser(String userId) {
    return _firestore
        .collection('user_wallpapers')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return Wallpaper.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList());
  }
}
