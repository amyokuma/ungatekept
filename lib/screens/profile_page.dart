import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Loaf/providers/auth.dart';
import 'package:Loaf/screens/auth_page.dart';
import 'package:Loaf/widget/menu.dart';
import 'package:Loaf/screens/landmark_details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@')[0] ?? 'Guest';

    return AppNavScaffold(
      initialIndex: 4, // Assuming profile is the 4th item in menu
      body: CustomScrollView(
        slivers: [
          // App Bar - Same as HomePage
          SliverAppBar(
            backgroundColor: const Color(0xfff8f4f3),
            pinned: true,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Image.asset(
                'assets/images/loaf_transparent.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              tooltip: 'Home',
            ),
            title: Text(
              'Loaf',
              style: TextStyle(
                fontFamily: 'GamabadoSans',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Profile Header Section
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xfff8f4f3),
              child: Column(
                children: [
                  // Username and Logout Button Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '@$username',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff41342b),
                          ),
                        ),
                        StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return TextButton.icon(
                                onPressed: () {
                                  Auth().signOut(context: context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => AuthPage()),
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  size: 18,
                                  color: Color(0xff41342b),
                                ),
                                label: const Text(
                                  'Log out',
                                  style: TextStyle(
                                    color: Color(0xff41342b),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  backgroundColor: const Color(0xff41342b).withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            }
                            return TextButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => AuthPage()),
                                );
                              },
                              icon: const Icon(
                                Icons.login,
                                size: 18,
                                color: Color(0xff41342b),
                              ),
                              label: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xff41342b),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: const Color(0xff41342b).withOpacity(0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff41342b).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xff41342b).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xff41342b),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Username below profile picture
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff41342b),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Followers/Following Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          number: '127',
                          label: 'Followers',
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xff41342b).withOpacity(0.2),
                        ),
                        _StatColumn(
                          number: '89',
                          label: 'Following',
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: const Color(0xff41342b).withOpacity(0.2),
                        ),
                        _StatColumn(
                          number: '24',
                          label: 'Posts',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Edit Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to edit profile
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        side: const BorderSide(color: Color(0xff41342b)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xff41342b),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity Label
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xff41342b).withOpacity(0.05),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xff41342b).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff41342b),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent Activity Feed - Using similar layout as HomePage
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            sliver: SliverList.builder(
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _UserPostTile(
                    title: post.title,
                    description: post.description,
                    imageUrl: post.imageUrl,
                    latitude: post.latitude,
                    longitude: post.longitude,
                    timestamp: post.timestamp,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Column Widget for Followers/Following
class _StatColumn extends StatelessWidget {
  final String number;
  final String label;

  const _StatColumn({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff41342b),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xff41342b).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// User Post Tile - Similar to LocationTile but with timestamp
class _UserPostTile extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String timestamp;

  const _UserPostTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            timestamp,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xff41342b).withOpacity(0.6),
            ),
          ),
        ),
        // Post Card - Same as HomePage LocationTile
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: Ink.image(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandmarkDetailPage(
                            name: title,
                            location: 'San Francisco, CA',
                            imageUrl: imageUrl,
                            description: description,
                            latitude: latitude,
                            longitude: longitude,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.1, 1.0],
                      colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Mock user posts data
class _UserPost {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String timestamp;

  const _UserPost(
    this.title,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.timestamp,
  );
}

// Placeholder user posts - replace with actual database fetch
const _userPosts = <_UserPost>[
  _UserPost(
    'Golden Gate Bridge Viewpoint',
    'Found this amazing spot for sunset photos near Battery Spencer.',
    'https://www.history.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MTY1MTc1MTk3ODI0MDAxNjA5/golden-gate-bridge-gettyimages-177770941.jpg',
    37.8324,
    -122.4795,
    '2 hours ago',
  ),
  _UserPost(
    'Lands End Lookout',
    'Perfect trail for a morning walk with incredible ocean views.',
    'https://cdn.shopify.com/s/files/1/0559/5065/9579/files/lands-end-lookout-trail-san-francisco.jpg',
    37.7854,
    -122.5057,
    '1 day ago',
  ),
  _UserPost(
    'Sutro Baths',
    'Exploring the historic ruins at low tide - such a unique spot!',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Sutro_Baths_ruins%2C_San_Francisco_%282019%29_-1.jpg/1200px-Sutro_Baths_ruins%2C_San_Francisco_%282019%29_-1.jpg',
    37.7804,
    -122.5138,
    '3 days ago',
  ),
  _UserPost(
    'Crissy Field',
    'Great picnic spot with views of the Golden Gate and Alcatraz.',
    'https://www.presidio.gov/sites/default/files/styles/hero_lighter/public/2021-11/20200325-GGNRA-BradleyDunn-CrissyField-9631.jpg',
    37.8037,
    -122.4666,
    '5 days ago',
  ),
  _UserPost(
    'Twin Peaks',
    '360-degree views of the entire city - best at sunrise!',
    'https://california.com/sites/default/files/styles/article_hero/public/Twin%20Peaks%2C%20San%20Francisco.jpeg',
    37.7544,
    -122.4477,
    '1 week ago',
  ),
];