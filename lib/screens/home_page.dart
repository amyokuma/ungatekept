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
                    tags: item.tags,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (snapshot.hasData) {
            return FloatingActionButton.extended(
              onPressed: () {
                Auth().signOut(context: context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
              label: const Text('Log out'),
              icon: const Icon(Icons.person),
              backgroundColor: const Color(0xff41342b),
            );
          }

          final user = snapshot.data!;
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            },
            label: const Text('Login / Sign Up'),
            icon: const Icon(Icons.person),
            backgroundColor: const Color(0xff41342b),
          );
        },
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
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
  final List<String> tags;

  const _LocationTile({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 14 / 11,
            child: Ink.image(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              child: InkWell(onTap: () {}),
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
                  stops: const [0, 1],
                  colors: [Colors.transparent, Colors.black.withOpacity(0.78)],
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
  final List<String> tags;

  const _Location(this.title, this.description, this.imageUrl, this.tags);
}

const _mockMenu = <_Location>[
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
    ['Pond', 'Architecture', 'Landmark'],
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    ['Pond', 'Architecture', 'Landmark'],
  ),
];
