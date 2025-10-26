import 'package:Loaf/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:Loaf/screens/home_page.dart';
import 'package:Loaf/screens/add_page.dart';

class AppNavScaffold extends StatefulWidget {
  final Widget body;
  final int initialIndex;

  const AppNavScaffold({
    Key? key,
    required this.body,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<AppNavScaffold> createState() => _AppNavScaffoldState();
}

class _AppNavScaffoldState extends State<AppNavScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      // TODO: Navigate to Your Lists page
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 2) {
      final prevIndex = _selectedIndex;
      setState(() {
        _selectedIndex = index;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPage()),
      );
      // After returning from AddPage, reset to previous index so Add Slice can be tapped again
      setState(() {
        _selectedIndex = prevIndex;
      });
    } else if (index == 3) {
      // TODO: Navigate to Friends page
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.brown[200],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Your Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: 'Add Slice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
