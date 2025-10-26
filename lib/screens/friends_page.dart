import 'package:flutter/material.dart';
import 'package:Loaf/widgets/menu.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppNavScaffold(
      initialIndex: 3, // 3 = 'Friends' tab
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Friends',
                        style: TextStyle(
                          color: Color(0xff41342b),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Placeholder for friends list
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No friends yet! Invite some friends to get started.',
                style: TextStyle(
                  color: Color(0xff795548),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
