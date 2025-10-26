import 'package:flutter/material.dart';
import 'package:Loaf/providers/auth.dart';
import 'package:Loaf/screens/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Loaf/screens/landmark_details_page.dart';
import 'package:Loaf/screens/add_page.dart';
import 'package:Loaf/widget/menu.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Loaf/config/api_keys.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavScaffold(
      initialIndex: 0,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xfff8f4f3),
                pinned: true,
                elevation: 0,
                centerTitle: false,
                leading: null,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.brown),
                    onPressed: () {}, // For show only
                    tooltip: 'Notifications',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.brown),
                      onPressed: () {}, // For show only
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
                    child: _SearchField(),
                  ),
                ),
              ),


              // ---- WEATHER INFO SECTION ----
              SliverToBoxAdapter(
                child: _WeatherInfoSection(),
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

// --- Weather Info Section --------------------------------------------------

            ],
          ),
          // Removed log out button from home page
        ],
      ),
    );
  }
}

// --- Widgets ---------------------------------------------------------------

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 36,
        width: double.infinity,
        child: TextField(
          style: const TextStyle(color: Color(0xff795548)),
          cursorColor: Color(0xff795548),
          decoration: InputDecoration(
            hintText: 'Search for a chill spot',
            hintStyle: const TextStyle(color: Color(0xff795548)),
            prefixIcon: const Icon(Icons.search, color: Color(0xff795548)),
            filled: true,
            fillColor: Color(0xffe0e0e0), // gray
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
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
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 14 / 11,
            child: GestureDetector(
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
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
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
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
    );
  }
}

// --- Weather Info Section --------------------------------------------------
class _WeatherInfoSection extends StatefulWidget {
  const _WeatherInfoSection({Key? key}) : super(key: key);

  @override
  State<_WeatherInfoSection> createState() => _WeatherInfoSectionState();
}

class _WeatherInfoSectionState extends State<_WeatherInfoSection> {
  String? weatherType;
  String? weatherDesc;
  double? tempF;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          error = 'Location services are disabled.';
          loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            error = 'Location permissions are denied.';
            loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          error = 'Location permissions are permanently denied.';
          loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final apiKey = ApiKeys.weatherAPIKey;
      final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherType = data['current']['condition']['text'].toString().toLowerCase();
          weatherDesc = data['current']['condition']['text'];
          tempF = (data['current']['temp_f'] as num?)?.toDouble();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch weather.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  String getWeatherMessage() {
    if (weatherType == null) return '';
    if (weatherType!.contains('sunny')) {
      return "It's a sunny day today, here are some outdoor chill spots:";
    } else if (weatherType!.contains('rain')) {
      return "It's a rainy day today, here are some cozy indoor chill spots:";
    } else if (weatherType!.contains('cloud')) {
      return "It's a cloudy day today, here are some cozy indoor chill spots:";
    } else if (weatherType!.contains('snow')) {
      return "It's a snowy day today, here are some warm indoor chill spots:";
    } else {
      return "Here are some chill spots for you:";
    }
  }

  IconData getWeatherIcon() {
    if (weatherType == null) return Icons.place;
    if (weatherType!.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (weatherType!.contains('rain')) {
      return Icons.umbrella;
    } else if (weatherType!.contains('cloud')) {
      return Icons.cloud;
    } else if (weatherType!.contains('snow')) {
      return Icons.ac_unit;
    } else {
      return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: loading
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      children: [
                        Icon(
                          getWeatherIcon(),
                          color: Colors.amber[700],
                          size: 32,
                        ),
                        if (tempF != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${tempF!.toStringAsFixed(0)}°F',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff41342b),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
                child: error != null
                    ? Text(
                        error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      )
                    : loading
                        ? const Text('Fetching weather...')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weatherDesc ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff41342b),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getWeatherMessage(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff41342b),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
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
    37.8025, // latitude
    -122.4488, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7749, // latitude
    -122.4194, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596, // latitude
    -122.4269, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596, // latitude
    -122.5107, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596, // latitude
    -122.4269, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596, // latitude
    -122.4269, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.7596, // latitude
    -122.4269, // longitude
  ),
  _Location(
    'Palace of Fine Arts',
    'A historic landmark surrounded by a serene pond.',
    'https://offloadmedia.feverup.com/secretsanfrancisco.com/wp-content/uploads/2022/05/13025636/palace-of-fine-arts-sf.jpg',
    37.8052, // latitude
    -122.4652, // longitude
  ),
];
