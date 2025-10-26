import 'package:flutter/material.dart';
import 'package:Loaf/widgets/menu.dart';

class YourListsPage extends StatelessWidget {
  const YourListsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for lists
    final List<Map<String, dynamic>> lists = [
      {
        'title': 'All posts',
        'coverImages': [
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=200',
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=200',
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=200',
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=200',
        ],
        'icon': Icons.collections_bookmark,
      },
      {
        'title': 'Shops products',
        'coverImages': [
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=200',
          null, null, null,
        ],
        'icon': Icons.shopping_bag,
      },
    ];

    return AppNavScaffold(
      initialIndex: 1, // 1 = 'Your Lists' tab
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xfff8f4f3),
            pinned: true,
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: null,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.brown),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              Padding(
                padding: const EdgeInsets.only(right: 7.0),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.brown),
                  onPressed: () {},
                  tooltip: 'Menu',
                ),
              ),
            ],
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/loaf_transparent.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'Loaf',
                  style: TextStyle(
                    fontFamily: 'GamabadoSans',
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Saved',
                        style: TextStyle(
                          color: Color(0xff41342b),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xff795548)),
                        onPressed: () {},
                        tooltip: 'Add List',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final list = lists[index];
                  return _ListCard(
                    title: list['title'],
                    coverImages: list['coverImages'],
                    icon: list['icon'],
                  );
                },
                childCount: lists.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<String?> coverImages;
  final IconData icon;

  const _ListCard({
    required this.title,
    required this.coverImages,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2x2 grid for cover images
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(4, (i) {
                  final img = i < coverImages.length ? coverImages[i] : null;
                  if (img != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xfff8f4f3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                    );
                  }
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xff795548), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff41342b),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
