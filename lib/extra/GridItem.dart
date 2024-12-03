import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final String imageUrl;

  const GridItem({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Container(color: Colors.grey[300]),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
