import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:Loaf/config/api_keys.dart';

class SearchSpotScreen extends StatefulWidget {
  const SearchSpotScreen({Key? key}) : super(key: key);

  @override
  State<SearchSpotScreen> createState() => _SearchSpotScreenState();
}

class _SearchSpotScreenState extends State<SearchSpotScreen> {
  final TextEditingController _spotController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _citySuggestions = [];
  bool _isLoadingCities = false;
  String? _selectedLatLng;

  @override
  void dispose() {
    _spotController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _citySuggestions = []);
      return;
    }
    setState(() => _isLoadingCities = true);
    final apiKey = ApiKeys.googleMapsAPIKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$apiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List<dynamic>?;
        setState(() {
          _citySuggestions = predictions?.map((e) => {
            'description': e['description'],
            'place_id': e['place_id'],
          }).toList() ?? [];
        });
      } else {
        setState(() => _citySuggestions = []);
      }
    } catch (_) {
      setState(() => _citySuggestions = []);
    }
    setState(() => _isLoadingCities = false);
  }

  Future<void> _selectCity(String description, String placeId) async {
    // Get lat/lng for the selected place
    final apiKey = ApiKeys.googleMapsAPIKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        setState(() {
          _locationController.text = description;
          _selectedLatLng = '${location['lat']},${location['lng']}' ;
          _citySuggestions = [];
        });
      }
    } catch (_) {}
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingCities = true);
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLatLng = '${position.latitude},${position.longitude}';
        _locationController.text = 'Current Location';
        _citySuggestions = [];
      });
    } catch (_) {
      // Handle error
    }
    setState(() => _isLoadingCities = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xfff8f4f3),
        appBar: AppBar(
          backgroundColor: const Color(0xfff8f4f3),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Image.network(
                    'https://storage.googleapis.com/calhacks-picture-bucket/loaf_transparent.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xff795548)),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar below loaf
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xffe0e0e0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _spotController,
                  autofocus: true,
                  style: const TextStyle(color: Color(0xff795548)),
                  cursorColor: Color(0xff795548),
                  decoration: InputDecoration(
                    hintText: 'Search for a chill spot',
                    hintStyle: const TextStyle(color: Color(0xff795548)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xff795548)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  ),
                ),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xffe0e0e0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Color(0xff795548)),
                  cursorColor: Color(0xff795548),
                  decoration: InputDecoration(
                    hintText: 'Location',
                    hintStyle: const TextStyle(color: Color(0xff795548)),
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xff795548)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  ),
                  onChanged: (value) {
                    _fetchCitySuggestions(value);
                  },
                  onTap: () {
                    if (_locationController.text.isNotEmpty) {
                      _fetchCitySuggestions(_locationController.text);
                    }
                  },
                ),
              ),
              if (_isLoadingCities)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              if (!_isLoadingCities && _citySuggestions.isNotEmpty)
                ..._citySuggestions.map((city) => ListTile(
                      title: Text(city['description'] ?? ''),
                      onTap: () => _selectCity(city['description'], city['place_id']),
                    )),
              ListTile(
                leading: const Icon(Icons.my_location, color: Color(0xff795548)),
                title: const Text('Use Current Location'),
                onTap: _useCurrentLocation,
              ),
              const SizedBox(height: 24),
              // Add more UI for search results, suggestions, etc. here
            ],
          ),
        ),
      ),
    );
  }
}
