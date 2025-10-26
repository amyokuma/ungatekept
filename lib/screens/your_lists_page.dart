import 'package:flutter/material.dart';
import 'package:Loaf/widgets/menu.dart';

class YourListsPage extends StatelessWidget {
  const YourListsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for lists
    final List<Map<String, dynamic>> lists = [
      {
        'title': 'All saved',
        'coverImages': [null, null, null, null],
        'icon': Icons.collections_bookmark,
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
                Image.network(
                  'https://storage.googleapis.com/calhacks-picture-bucket/loaf_transparent.png',
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
                        'Your Lists',
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
            child: Center(
              child: Text(
                '0 slices saved',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
