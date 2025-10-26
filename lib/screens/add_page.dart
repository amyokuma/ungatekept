// import 'package:Loaf/providers/firestore.dart';
import 'package:Loaf/providers/auth.dart';
import 'package:Loaf/services/AddLocationService.dart';
import 'package:Loaf/services/LocationService.dart';
import 'package:Loaf/services/ReviewServices.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:Loaf/config/api_keys.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  int _rating = 0;

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((x) => File(x.path)).toList();
      });
    }
  }
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _auth = Auth();
  final _locationService = LocationService();
  final _reviewService = ReviewService();
  // final _firestoreService = FirestoreService();
  
  List<String> _selectedCategories = [];
  final List<String> _categories = [
    'Cozy',
    'Modern',
    'Rustic',
    'Historic',
    'Urban',
    'Rural',
    'Seaside',
    'Mountain',
    'Indoor',
    'Outdoor',
    'Scenic',
    'Luxurious',
    'Minimalist',
    'Vibrant',
    'Quiet',
    'Remote',
    'Central',
    'Family-Friendly',
    'Romantic',
    'Pet-Friendly',
    'Spacious',
    'Compact',
    'Cultural',
    'Natural',
    'Trendy',
  ];

  bool _isLoadingLocation = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _locationSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  GeoPoint? _userLocation;
  List<LocationWithDistance>? _nearbyLocations;
  String? userId;
  String? locationId;
  List<String> tags = ["test"];

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError(
          'Location services are disabled. Please enable them in settings.',
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // fetch nearby locations
      _userLocation = GeoPoint(position.latitude, position.longitude);

      final results = await _locationService.findNearbyLocations(
        _userLocation!,
      );

      // Update the text fields, locations list
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _isLoadingLocation = false;
        _nearbyLocations = results;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location fetched successfully!'),
          backgroundColor: Color(0xff795548),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showError('Failed to get location: ${e.toString()}');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xffb71c1c), // deep red for errors
        duration: const Duration(seconds: 3),
      ),
    );
  }


  Future<void> _saveLandmark() async {
  // Validate the form first
  if (_formKey.currentState?.validate() ?? false) {
    // Extract data from controllers
    final name = _nameController.text.trim();
    final review = _reviewController.text.trim();
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    final categories = _selectedCategories;

    // Check if latitude and longitude are valid numbers
    if (latitude == null || longitude == null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid latitude and longitude'),
        ),
      );
      return;
    }

    // Create a map or model object to send to database
    final landmarkData = {
      'name': name,
      'review': review,
      'latitude': latitude,
      'longitude': longitude,
      'tags': categories
    };

    try {
      // Use your Maps API key (same one you're using for Static Maps)
      final apiKey = '${ApiKeys.googleMapsAPIKey}';

      // Google Places Autocomplete API
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=${Uri.encodeComponent(query)}'
        '&types=(cities)' // Only cities
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;

          List<Map<String, dynamic>> suggestions = [];

          // Get coordinates for each city (up to 5 results)
          for (var prediction in predictions.take(5)) {
            final placeId = prediction['place_id'];

            // Get place details including coordinates
            final detailsUrl = Uri.parse(
              'https://maps.googleapis.com/maps/api/place/details/json?'
              'place_id=$placeId'
              '&fields=geometry'
              '&key=$apiKey',
            );

            final detailsResponse = await http.get(detailsUrl);

            if (detailsResponse.statusCode == 200) {
              final detailsData = json.decode(detailsResponse.body);

              if (detailsData['status'] == 'OK') {
                final result = detailsData['result'];
                final location = result['geometry']['location'];

                suggestions.add({
                  'name': prediction['description'],
                  'lat': location['lat'],
                  'lng': location['lng'],
                });
              }
            }
          }

          setState(() {
            _locationSuggestions = suggestions;
            _isSearching = false;
          });
        } else {
          // Handle API errors
          print('Places API error: ${data['status']}');
          _showError('Error searching locations. Please try again.');
          setState(() {
            _isSearching = false;
            _showSuggestions = false;
          });
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        _showError('Network error. Please check your connection.');
        setState(() {
          _isSearching = false;
          _showSuggestions = false;
        });
      }
    } catch (e) {
      print('Error searching locations: $e');
      _showError('Failed to search locations.');
      setState(() {
        _isSearching = false;
        _showSuggestions = false;
      });
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _locationController.text = location['name'];
      _latitudeController.text = location['lat'].toString();
      _longitudeController.text = location['lng'].toString();
      _showSuggestions = false;
    });
  }

  Future<void> _saveLandmark() async {
    // get location id if not exist
    userId = await _auth.getCurrentUser();

    if (userId == null) {
      throw Exception("not logged in?");
    }

    if (_formKey.currentState!.validate()) {
      try {
        if (locationId != null) {
          await _locationService.addLocation(
            name: _nameController.text,
            coords: GeoPoint(_userLocation!.latitude, _userLocation!.longitude),
            tags: tags,
            description: _descriptionController.text,
          );
        } else {
          locationId = await _reviewService.getNextID();

          await _reviewService.addReview(
            userId: userId!,
            locationId: locationId!,
            rating: 5,
            description: _descriptionController.text,
            pictureUrl: "TODO",
          );
        }
      } catch (e) {
        throw Exception("error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Landmark saved successfully!'),
          backgroundColor: Color(0xFF9333EA),
        ),
      );
      Navigator.pop(context);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f4f3),
      appBar: AppBar(
        backgroundColor: const Color(0xfff8f4f3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xff41342b)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Slice',
          style: TextStyle(
            color: Color(0xff41342b),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveLandmark,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xff795548),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Multi-image upload section
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 200, maxHeight: 320),
                  decoration: BoxDecoration(
                    color: const Color(0xffe7dfd8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffd2c2b2), width: 2, style: BorderStyle.solid),
                  ),
                  child: _selectedImages.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GridView.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(_selectedImages.length, (idx) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.file(
                                      _selectedImages[idx],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(idx);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate, size: 48, color: Color(0xffbca18c)),
                            const SizedBox(height: 8),
                            const Text(
                              'Add Photo(s)',
                              style: TextStyle(
                                color: Color(0xff795548),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Coordinates section (moved up)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Coordinates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff41342b),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff795548)),
                            ),
                          )
                        : const Icon(Icons.my_location, size: 18, color: Color(0xff795548)),
                    label: Text(_isLoadingLocation ? 'Getting location...' : 'Use My Location'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xff795548),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      hint: '37.8199',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      hint: '-122.4783',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name field
              _buildTextField(
                controller: _nameController,
                label: 'Landmark Name',
                hint: 'e.g., Golden Gate Bridge',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rating input
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff41342b),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xff795548),
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // Multi-select category dropdown
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff41342b),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final List<String> result = await showDialog(
                    context: context,
                    builder: (context) {
                      List<String> tempSelected = List.from(_selectedCategories);
                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            title: const Text('Select categories'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView(
                                shrinkWrap: true,
                                children: _categories.map((category) {
                                  return CheckboxListTile(
                                    value: tempSelected.contains(category),
                                    title: Text(category),
                                    onChanged: (checked) {
                                      setStateDialog(() {
                                        if (checked == true) {
                                          tempSelected.add(category);
                                        } else {
                                          tempSelected.remove(category);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(_selectedCategories),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(tempSelected),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ) ?? _selectedCategories;
                  setState(() {
                    _selectedCategories = result;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe7dfd8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedCategories.isEmpty
                              ? 'Select categories'
                              : _selectedCategories.join(', '),
                          style: TextStyle(
                            color: _selectedCategories.isEmpty
                                ? const Color(0xffbca18c)
                                : const Color(0xff41342b),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xffbca18c)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: _selectedCategories.map((cat) => Chip(
                  label: Text(cat),
                  onDeleted: () {
                    setState(() {
                      _selectedCategories.remove(cat);
                    });
                  },
                )).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // review field
              _buildTextField(
                controller: _reviewController,
                label: 'Review',
                hint: 'Tell us your thoughts on this location...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a review';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLandmark,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff795548),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Slice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff41342b),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xffbca18c)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xffe7dfd8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xffe7dfd8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff795548), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffb71c1c), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
