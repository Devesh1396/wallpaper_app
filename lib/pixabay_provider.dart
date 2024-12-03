import 'package:flutter/material.dart';
import 'package:wallpaper_app/pixabay_api.dart';

class PixabayProvider with ChangeNotifier {
  final PixabayApiService _apiService = PixabayApiService();

  List<dynamic> _wallpapers = [];
  List<dynamic> _trendingWallpapers = [];
  List<dynamic> _categoryWallpapers = [];
  List<dynamic> _colorWallpapers = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<dynamic> get wallpapers => _wallpapers;
  List<dynamic> get trendingWallpapers => _trendingWallpapers;
  List<dynamic> get categoryWallpapers => _categoryWallpapers;
  List<dynamic> get colorWallpapers => _colorWallpapers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  // New method to check if wallpapers are fully loaded
  bool get isFullyLoaded => !_isLoading && _wallpapers.isNotEmpty;

  // Fetch random wallpapers (initial load)
  Future<void> fetchRandomWallpapers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1; // Reset to the first page
      _wallpapers = await _apiService.fetchRandomWallpapers(page: _currentPage);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch random wallpapers for Sign-Up Page
  Future<void> fetchSignupWallpapers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wallpapers = await _apiService.fetchRandomWallpapers(perPage: 40, page: 4); // Different page & more items
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch more wallpapers for pagination (random)
  Future<void> fetchMoreWallpapers() async {
    if (_isLoadingMore) return; // Prevent duplicate calls

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++; // Increment page number
      final newWallpapers = await _apiService.fetchRandomWallpapers(page: _currentPage);
      _wallpapers.addAll(newWallpapers);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch trending wallpapers (initial load)
  Future<void> fetchTrendingWallpapers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1; // Reset to the first page
      _trendingWallpapers = await _apiService.fetchTrendingWallpapers(page: _currentPage);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more trending wallpapers (pagination)
  Future<void> loadMoreTrendingWallpapers() async {
    if (_isLoadingMore) return; // Prevent multiple simultaneous loads

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++; // Move to the next page
      final newWallpapers = await _apiService.fetchTrendingWallpapers(page: _currentPage);
      _trendingWallpapers.addAll(newWallpapers);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategoryWallpapers(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1; // Reset pagination
      _categoryWallpapers.clear();
      _categoryWallpapers = await _apiService.searchWallpapers(category, page: _currentPage);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCategoryWallpapers(String category) async {
    if (_isLoadingMore) return; // Prevent concurrent loading
    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final List<dynamic> newWallpapers = await _apiService.searchWallpapers(category, page: _currentPage);
      _categoryWallpapers.addAll(newWallpapers);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchWallpapersByColor(String colorName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPage = 1; // Reset pagination
      _colorWallpapers.clear();
      _colorWallpapers = await _apiService.ColorbasedWallpapers(colorName, page: _currentPage);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreColorWallpapers(String colorName) async {
    if (_isLoadingMore) return; // Prevent concurrent loading
    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final List<dynamic> newWallpapers = await _apiService.ColorbasedWallpapers(colorName, page: _currentPage);
      _colorWallpapers.addAll(newWallpapers);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
