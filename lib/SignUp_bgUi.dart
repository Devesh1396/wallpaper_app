import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'pixabay_provider.dart';

class SignupBackground extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<PixabayProvider>(
      builder: (context, provider, child) {
        // Trigger image fetching if wallpapers list is empty
        if (provider.wallpapers.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchSignupWallpapers();
          });
        }

        // Display black screen while loading or not fully loaded
        if (provider.isLoading || !provider.isFullyLoaded) {
          return Container(
            color: Colors.black, // Full black background while loading
          );
        }

        // Handle errors
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Error: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // Once fully loaded, process and display the UI
        final List<dynamic> column1Images = provider.wallpapers
            .asMap()
            .entries
            .where((entry) => entry.key % 3 == 0)
            .map((entry) => entry.value)
            .toList();
        final List<dynamic> column2Images = provider.wallpapers
            .asMap()
            .entries
            .where((entry) => entry.key % 3 == 1)
            .map((entry) => entry.value)
            .toList();
        final List<dynamic> column3Images = provider.wallpapers
            .asMap()
            .entries
            .where((entry) => entry.key % 3 == 2)
            .map((entry) => entry.value)
            .toList();

        return Row(
          children: [
            // Column 1
            _buildCarouselColumn(
              context,
              column1Images,
              autoPlayInterval: const Duration(milliseconds: 800),
              autoPlayAnimationDuration: const Duration(seconds: 4),
            ),
            // Column 2
            _buildCarouselColumn(
              context,
              column2Images,
              autoPlayInterval: const Duration(milliseconds: 100), // Shorter interval
              autoPlayAnimationDuration: const Duration(seconds: 1), // Almost matching
            ),
            // Column 3
            _buildCarouselColumn(
              context,
              column3Images,
              autoPlayInterval: const Duration(milliseconds: 500),
              autoPlayAnimationDuration: const Duration(seconds: 3),
            ),
          ],
        );
      },
    );
  }



  // Helper function to build a column with carousel slider
  Widget _buildCarouselColumn(BuildContext context, List<dynamic> wallpapers, {required Duration autoPlayInterval, required Duration autoPlayAnimationDuration}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double itemHeight = screenHeight / 4; // 4 images visible at a time

    return SizedBox(
      width: screenWidth / 3, // Each column takes 1/3rd of the screen width
      child: CarouselSlider.builder(
        itemCount: wallpapers.length,
        itemBuilder: (context, index, realIndex) {
          final wallpaper = wallpapers[index];
          return Container(
            height: itemHeight,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
               boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: wallpaper['largeImageURL'],
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: screenHeight,
          autoPlay: true,
          autoPlayInterval: autoPlayInterval,
          autoPlayAnimationDuration: autoPlayAnimationDuration,
          scrollDirection: Axis.vertical,
          viewportFraction: 0.2,
          enableInfiniteScroll: true,
          scrollPhysics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

}
