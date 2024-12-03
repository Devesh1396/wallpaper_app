import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'GridWidget.dart';
import 'pixabay_provider.dart';

class SearchViewUI extends StatefulWidget {
  final String query;
  final bool isColor;

  const SearchViewUI({
    Key? key,
    required this.query,
    this.isColor = false,
  }) : super(key: key);

  @override
  _SearchViewUIState createState() => _SearchViewUIState();
}

class _SearchViewUIState extends State<SearchViewUI> {
  late AutoScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      _fetchInitialWallpapers(provider);
    });

    _controller.addListener(() {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      _loadMoreWallpapers(provider);
    });
  }

  void _fetchInitialWallpapers(PixabayProvider provider) {
    if (widget.isColor) {
      provider.fetchWallpapersByColor(widget.query);
    } else {
      provider.fetchCategoryWallpapers(widget.query);
    }
  }

  void _loadMoreWallpapers(PixabayProvider provider) {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore) {
      if (widget.isColor) {
        provider.loadMoreColorWallpapers(widget.query);
      } else {
        provider.loadMoreCategoryWallpapers(widget.query);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PixabayProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: provider.isLoading && provider.categoryWallpapers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text('Error: ${provider.errorMessage}'))
          : MasonryGridWidget(
        controller: _controller,
        wallpapers: widget.isColor
            ? provider.colorWallpapers
            : provider.categoryWallpapers,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
