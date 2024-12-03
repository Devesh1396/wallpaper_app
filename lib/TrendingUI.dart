import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'GridWidget.dart';
import 'pixabay_provider.dart';

class TrendingWallpapers extends StatefulWidget {
  @override
  _TrendingWallpapersState createState() => _TrendingWallpapersState();
}

class _TrendingWallpapersState extends State<TrendingWallpapers> {
  late AutoScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();

    // Delay provider call until after the current build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      provider.fetchTrendingWallpapers();
    });

    _controller.addListener(() {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200 &&
          !provider.isLoadingMore) {
        provider.loadMoreTrendingWallpapers();
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
      backgroundColor: Colors.white,
      body: provider.isLoading && provider.trendingWallpapers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text('Error: ${provider.errorMessage}'))
          : MasonryGridWidget(
        controller: _controller,
        wallpapers: provider.trendingWallpapers,
      ),
    );
  }
}
