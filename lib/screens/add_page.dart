import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';



class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  List<String> _selectedCategories = ['Cozy'];
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
  // Removed unused location search fields

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
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
        _showError('Location services are disabled. Please enable them in settings.');
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
        _showError('Location permissions are permanently denied. Please enable them in settings.');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the text fields
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _isLoadingLocation = false;
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





  void _saveLandmark() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save landmark data to database
      // For now, just navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Landmark saved successfully!'),
          backgroundColor: Color(0xff795548),
        ),
      );
      Navigator.pop(context);
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
              // Image upload placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xffe7dfd8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffd2c2b2), width: 2, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate, size: 48, color: Color(0xffbca18c)),
                    const SizedBox(height: 8),
                    const Text(
                      'Add Photo',
                      style: TextStyle(
                        color: Color(0xff795548),
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              
              // Description field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell us a little bit about this location...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}