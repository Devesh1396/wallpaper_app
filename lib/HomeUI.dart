import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wallpaper_app/AuthService.dart';
import 'package:wallpaper_app/MainProfileUI.dart';
import 'package:wallpaper_app/SignUp_UI.dart';
import 'GridWidget.dart';
import 'SearchViewUI.dart';
import 'pixabay_provider.dart';

class HomeUI extends StatefulWidget {
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  late AutoScrollController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();

    // Delay provider call until after the current build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      provider.fetchRandomWallpapers();
    });

    _controller.addListener(() {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          !provider.isLoadingMore) {
        provider.fetchMoreWallpapers();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PixabayProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2.0,
        toolbarHeight: 75,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search wallpapers...",
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchViewUI(query: query, isColor: false),
                ),
              ).then((_) {
                _searchController.clear();
              });
            }
          },
        ),
        actions: [
          Consumer<AutheProvider>(builder: (context, authProvider, _) {
            return IconButton(
              onPressed: () {
                if (!authProvider.isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpUI()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profileUI()),
                  );
                }
              },
              icon: CircleAvatar(
                backgroundImage: authProvider.photoURL.startsWith("http")
                    ? CachedNetworkImageProvider((authProvider.photoURL))
                    : AssetImage(authProvider.photoURL) as ImageProvider,
              ),
            );
          }),
        ],
      ),
      body: provider.isLoading && provider.wallpapers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text('Error: ${provider.errorMessage}'))
              : MasonryGridWidget(
                  controller: _controller,
                  wallpapers: provider.wallpapers,
                ),
    );
  }
}
