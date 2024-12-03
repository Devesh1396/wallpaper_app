import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/SearchViewUI.dart';
import 'package:wallpaper_app/TrendingUI.dart';
import 'Dataconstants.dart';

class CategoriesUI extends StatefulWidget {
  @override
  _CategoriesUIState createState() => _CategoriesUIState();
}

class _CategoriesUIState extends State<CategoriesUI> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorColor: Colors.blueAccent,
          overlayColor: WidgetStateProperty.all(
              Colors.transparent),
          tabs: const [
            Tab(text: "Categories"),
            Tab(text: "Colors"),
            Tab(text: "Trending"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(),
          _buildColorsTab(),
          _buildTrendingTab(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final category_name = categories[index]["title"] ?? "Default Title";
        return GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchViewUI(
                  query: category_name,
                  isColor: false,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: category["image_url"]!,
                    height: 150,
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Overlay
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // Text
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    category["title"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: colorList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchViewUI(
                  query: colorNames[index],
                  isColor: true,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: colorList[index],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    return TrendingWallpapers();
  }
}
