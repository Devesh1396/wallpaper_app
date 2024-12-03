import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayApiService {
  final String _baseUrl = 'https://pixabay.com/api/';
  final String _apiKey = '47161468-6eb62c3cd48462dd9df90f431';

  // Fetch random wallpapers (default to 20 per page)
  Future<List<dynamic>> fetchRandomWallpapers({int perPage = 20, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&image_type=photo&per_page=$perPage&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  // Fetch wallpapers by category
  Future<List<dynamic>> fetchWallpapersByCategory(String category, {int perPage = 20, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&q=$category&image_type=photo&per_page=$perPage&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load wallpapers by category');
    }
  }

  // Fetch trending wallpapers (default to 20 per page)
  Future<List<dynamic>> fetchTrendingWallpapers({int perPage = 20, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&image_type=photo&order=trending&per_page=$perPage&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to load trending wallpapers');
    }
  }


  // Search wallpapers
  Future<List<dynamic>> searchWallpapers(String query, {int perPage = 20, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&q=$query&image_type=photo&per_page=$perPage&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to fetch wallpapers');
    }
  }

  // Wallpapers By Colors
  Future<List<dynamic>> ColorbasedWallpapers(String color_name, {int perPage = 20, int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&colors=$color_name&image_type=photo&per_page=$perPage&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hits'];
    } else {
      throw Exception('Failed to fetch wallpapers');
    }
  }

}
