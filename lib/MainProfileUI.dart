import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AuthService.dart';

class profileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();

  final bool showBackButton;

  profileUI({this.showBackButton = true});

}

class _ProfileUIState extends State<profileUI> {
  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 30 &&
          !_scrollController.position.outOfRange) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else if (_scrollController.offset <= 30 &&
          !_scrollController.position.outOfRange) {
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AutheProvider>(context);

    return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 90.0,
                  collapsedHeight: 60.0,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: widget.showBackButton && _isScrolled
                        ? Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                        : null,
                    titlePadding: EdgeInsets.symmetric(horizontal: 8.0),
                    background: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.showBackButton)
                              IconButton(
                                icon: Icon(
                                    Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            Text(
                              'Profile',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            IconButton(
                              icon: Icon(
                                  Icons.edit, color: Theme.of(context).primaryColor),
                              onPressed: () {
                                //
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _profileTop(authProvider),
                        SizedBox(height: 20),
                        _buildMenu(authProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _profileTop(AutheProvider authProvider) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: authProvider.photoURL.startsWith("http")
                ? CachedNetworkImageProvider((authProvider.photoURL))
                : AssetImage(authProvider.photoURL) as ImageProvider,
          ),
          SizedBox(height: 10),
          Text(
            authProvider.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )
          ),
          Text(
              authProvider.currentUser?.email ?? "No Email Found",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(AutheProvider authProvider) {
    return Container(
        child: Column(
      children: [
        _buildMenuItem(Icons.person, "Profile", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.note_alt_rounded, "Budget Settings", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.history, "Previous Statements", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.settings, "Settings", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.support, "Support", () {}),
        _buildDivider(),
        _buildMenuItem(Icons.logout, "Logout", () {
          authProvider.signOut(); // Call the sign-out method
          Navigator.pushReplacementNamed(context, '/home');
        }),
        _buildDivider(),
        _buildMenuItem(Icons.info_outline, "App Info", () {}),
      ],
    ));
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
