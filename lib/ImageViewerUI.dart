import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:provider/provider.dart';
import 'datamodel.dart';
import 'firestore_service.dart';
import 'AuthService.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  int _bottomNavIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> saveWallpaper(BuildContext context, String imageUrl) async {
    final authProvider = Provider.of<AutheProvider>(context, listen: false);

    final String? userEmail = authProvider.getCurrentUserEmail();

    if (userEmail == null) {
      return;
    }

    final wallpaper = Wallpaper(
      userId: userEmail,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    final firestoreService = FirestoreService();

    try {
      await firestoreService.saveWallpaper(wallpaper);
      showToast("Wallpaper Saved Successfully");
    } catch (e) {
      showToast("Failed to Save. Please try again!");
      print("Error saving wallpaper: $e");
    }
  }

  Future<void> handleDownload(String imageUrl, bool isFree) async {
    // Check storage permission status
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      await saveImage(imageUrl, isFree);
    } else if (status.isDenied) {
      // Request permission
      PermissionStatus requestStatus =
          await Permission.manageExternalStorage.request();

      if (requestStatus.isGranted) {
        await saveImage(imageUrl, isFree);
      } else if (requestStatus.isPermanentlyDenied) {
        // Permission permanently denied, guide user to settings
        showToast("Permission permanently denied. Please enable it in settings.");
        openAppSettings();
      } else {
        // Permission denied
        showToast("Permission denied.");
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      showToast("Permission permanently denied. Please enable it in settings.");
      openAppSettings();
    }
  }

  void showDownloadOptions(
      BuildContext context, Function onFreeDownload, Function onPaidDownload) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      isDismissible: true,
      showDragHandle: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Choose Download Option",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Free Option
            ListTile(
              leading: Icon(Icons.image, color: Colors.white),
              title: Text(
                "Free (Low Resolution, Watermark)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                onFreeDownload();
              },
            ),

            Divider(color: Colors.grey[600]),

            // Paid Option
            ListTile(
              leading: Icon(Icons.hd, color: Colors.amber),
              title: Text(
                "Rs. 99 (HD, No Watermark)",
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                onPaidDownload();
              },
            ),

            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<Uint8List> addLogoWatermarkFromAsset(Uint8List imageBytes) async {
    // Load the logo as bytes from assets
    final Uint8List logoBytes = await rootBundle
        .load("assets/images/logo_wm.png")
        .then((data) => data.buffer.asUint8List());

    // Decode the original image
    img.Image mainImage = img.decodeImage(imageBytes)!;

    // Decode the logo image
    img.Image logoImage = img.decodeImage(logoBytes)!;

    // Resize the logo to fit (optional)
    final int logoWidth =
        (mainImage.width * 0.2).toInt(); // 20% of the main image width
    final int logoHeight =
        (logoWidth * (logoImage.height / logoImage.width)).toInt();
    logoImage = img.copyResize(logoImage, width: logoWidth, height: logoHeight);

    // Calculate position for the logo
    final int x =
        mainImage.width - logoWidth - 20; // 20px padding from the right
    final int y =
        mainImage.height - logoHeight - 20; // 20px padding from the bottom

    // Composite the logo onto the main image
    img.Image watermarkedImage =
        img.compositeImage(mainImage, logoImage, dstX: x, dstY: y);

    // Encode the modified image back to bytes
    return Uint8List.fromList(img.encodePng(watermarkedImage));
  }

  Future<void> saveImage(String imageUrl, bool isFree) async {
    try {
      // Fetch the image from the URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        showToast("Failed to fetch image from URL.");
        return;
      }

      final Uint8List imageBytes = response.bodyBytes;
      final Uint8List processedBytes = isFree
          ? await addLogoWatermarkFromAsset(imageBytes)
          : imageBytes;

      // Define WallNova folder in Pictures
      final directory = Directory('/storage/emulated/0/Pictures/WallNova');

      // Create WallNova directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save the file in WallNova directory
      final fileName = "wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(processedBytes);

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(filePath);

      if (result['isSuccess'] == true) {
        showToast("Image Downloaded Successfully");
      } else {
        showToast("Image saved but failed to add to gallery.");
      }
    } catch (e) {
      showToast("Error: $e");
    }
  }

  void showWallpaperOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      isDismissible: true,
      showDragHandle: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text("Home Screen", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await CropAndSetWallpaper(
                    imageUrl, WallpaperManager.HOME_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.white),
              title: Text("Lock Screen", style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await CropAndSetWallpaper(
                    imageUrl, WallpaperManager.LOCK_SCREEN);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.white),
              title: Text("Home & Lock Screen",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await CropAndSetWallpaper(
                    imageUrl, WallpaperManager.BOTH_SCREEN);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> CropAndSetWallpaper(String imageUrl, int wallpaperType) async {
    try {
      // Fetch the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/wallpaper.jpg';
        final tempFile = File(tempPath)..writeAsBytesSync(response.bodyBytes);

        // Crop the image
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: tempFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Wallpaper',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
          ],
        );

        if (croppedImage != null) {
          // Pass the cropped image path directly to setWallpaper
          await setWallpaper(croppedImage.path, wallpaperType);
        } else {
          print('Image cropping cancelled.');
        }
      } else {
        print('Failed to fetch image from URL.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> setWallpaper(String imagePath, int wallpaperType) async {
    try {
      // Set the wallpaper using flutter_wallpaper_manager
      final bool result = await WallpaperManager.setWallpaperFromFile(
        imagePath, // Use the provided imagePath directly
        wallpaperType,
      );

      if (result) {
        showToast("Wallpaper Set Successfully");
      } else {
        showToast("Failed to Set Wallpaper!");
      }
    } catch (e) {
      showToast("Error: $e");
    }
  }

  Future<void> showSignInDialog(BuildContext context, String imageUrl) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -25,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 30,
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Text section
                const Text(
                  "Sign up and get the full Wallnova experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "In order to save or download wallpapers, you need to be signed in. Signing up is free!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Buttons section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, '/signUp');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Log In or Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Maybe Later",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showToast(String message) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _bottomNavIndex = -1;
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return CachedNetworkImage(
            imageUrl: image['largeImageURL'],
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
            fit: BoxFit.cover,
          );
        },
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.pinned,
        snakeShape: SnakeShape.circle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        backgroundColor: Colors.black.withOpacity(0.7),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        snakeViewColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _bottomNavIndex,
        onTap: (index) async {
          setState(() {
            _bottomNavIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pop(context, {'index': _currentIndex}); // Back
              break;
            case 1:
              // Add to Favorites (Save)
              final authProvider =
                  Provider.of<AutheProvider>(context, listen: false);

              if (!authProvider.isLoggedIn) {
                // Show Sign-In Dialog
                showSignInDialog(
                    context, widget.images[_currentIndex]['largeImageURL']);
              } else {
                // Save Wallpaper
                await saveWallpaper(
                    context, widget.images[_currentIndex]['largeImageURL']);
              }
              break;
            case 2:
              final authProvider =
                  Provider.of<AutheProvider>(context, listen: false);

              if (!authProvider.isLoggedIn) {
                showSignInDialog(
                    context, widget.images[_currentIndex]['largeImageURL']);
              } else {
                showDownloadOptions(
                  context,
                  () async {
                    // Free Download
                    final imageUrl =
                        widget.images[_currentIndex]['largeImageURL'];
                    await handleDownload(imageUrl, true); // Free download
                  },
                  () async {
                    // Paid Download
                    final imageUrl =
                        widget.images[_currentIndex]['largeImageURL'];
                    await handleDownload(imageUrl, false); // Paid download
                  },
                );
              }
              break;
            case 3:
              //Set as Wallpaper
              final imageUrl = widget.images[_currentIndex]['largeImageURL'];
              showWallpaperOptions(context, imageUrl);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallpaper),
            label: 'Set Wallpaper',
          ),
        ],
      ),
    );
  }
}

