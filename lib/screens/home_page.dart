import 'package:flutter/material.dart';
import 'package:Loaf/providers/auth.dart';
import 'package:Loaf/screens/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xfff8f4f3),
            pinned: true,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {},
            ),
            title: const Text(
              'Loaf',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _SearchField(),
              ),
            ),
          ),

          // ---- 1-COLUMN SCROLLABLE LIST ----
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            sliver: SliverList.builder(
              itemCount: _mockMenu.length,
              itemBuilder: (context, index) {
                final item = _mockMenu[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LocationTile(
                    title: item.title,
                    description: item.description,
                    imageUrl: item.imageUrl,
                    latitude: item.latitude,
                    longitude: item.longitude,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
        backgroundColor: const Color(0xFF9333EA),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// --- Widgets ---------------------------------------------------------------

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white70,
      decoration: InputDecoration(
        hintText: 'Search for a chill spot',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xff41342b),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  const _LocationTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 11, // tweak to match your mock height
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mock data, replace with real data source later

class _Location {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  
  const _Location(
    this.title,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  );
}

const _mockMenu = <_Location>[
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.8025,  // latitude
    -122.4488, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7749,  // latitude
    -122.4194, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    ['Pond', 'Architecture', 'Landmark'],
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596,  // latitude
    -122.5107, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596,  // latitude
    -122.4269, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    ['Pond', 'Architecture', 'Landmark'],
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    ['Pond', 'Architecture', 'Landmark'],
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.8052,  // latitude
    -122.4652, // longitude
  ),
];