import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'AuthService.dart';
import 'datamodel.dart';
import 'firestore_service.dart';

class SavedWallpapers extends StatefulWidget {
  @override
  _SavedWallpapersState createState() => _SavedWallpapersState();
}

class _SavedWallpapersState extends State<SavedWallpapers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AutheProvider>(context);
    final userEmail = authProvider.currentUser?.email;

    if (userEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Saved Wallpapers"),
      ),
      body: StreamBuilder<List<Wallpaper>>(
        stream: FirestoreService().getWallpapersForUser(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No saved wallpapers found."));
          }

          final wallpapers = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            padding: const EdgeInsets.all(8.0),
            itemCount: wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = wallpapers[index];
              return GestureDetector(
                onTap: () {
                },
                child: CachedNetworkImage(
                  imageUrl: wallpaper.imageUrl,
                  placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

