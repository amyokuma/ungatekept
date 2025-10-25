import 'package:flutter/material.dart';

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
              'Ungatekept',
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

  const _LocationTile({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Full-width image card (single column)
          AspectRatio(
            aspectRatio: 16 / 11, // tweak to match your mock height
            child: Ink.image(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              child: InkWell(onTap: () {}),
            ),
          ),

          // Bottom gradient with title + description
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
                ],
              ),
            ),
          ),

          // Subtle inner border to keep edges crisp
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10, width: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
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
  const _Location(this.title, this.description, this.imageUrl);
}

const _mockMenu = <_Location>[
  _Location(
    'Palace of Fine Arts',
    'Short description here. Short description here. Short description here.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
  ),
  _Location(
    'Wing Wall',
    'Short description here. Short description here. Short description here.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
  ),
  _Location(
    'Ocean Beach',
    'Short description here. Short description here. Short description here.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
  ),
  _Location(
    'Dolores Park',
    'Short description here. Short description here. Short description here.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
  ),
  _Location(
    'Crissy Field',
    'Short description here. Short description here. Short description here.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
  ),
];
