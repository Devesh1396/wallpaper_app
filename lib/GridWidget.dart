import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'ImageViewerUI.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MasonryGridWidget extends StatefulWidget {
  final AutoScrollController controller;
  final List<dynamic> wallpapers;

  const MasonryGridWidget({
    Key? key,
    required this.controller,
    required this.wallpapers,
  }) : super(key: key);

  @override
  _MasonryGridWidgetState createState() => _MasonryGridWidgetState();
}

class _MasonryGridWidgetState extends State<MasonryGridWidget>
    with AutomaticKeepAliveClientMixin<MasonryGridWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MasonryGridView.count(
      controller: widget.controller,
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: widget.wallpapers.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final wallpaper = widget.wallpapers[index];
        return AutoScrollTag(
          key: ValueKey(index),
          controller: widget.controller,
          index: index,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    images: widget.wallpapers,
                    initialIndex: index,
                  ),
                ),
              );

              if (result != null) {
                widget.controller.scrollToIndex(
                  result['index'],
                  preferPosition: AutoScrollPosition.begin,
                  duration: const Duration(milliseconds: 800),
                );
              }
            },
            child: CachedNetworkImage(
              imageUrl: wallpaper['largeImageURL'],
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

