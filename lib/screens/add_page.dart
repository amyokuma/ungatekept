import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart'; // Make sure path is correct

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  int _rating = 0;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  // THIS IS THE KEY METHOD - pickMultiImage instead of pickImage
  Future<void> _pickImages() async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _reviewController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
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

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable them in settings.');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
        backgroundColor: const Color(0xffb71c1c),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveLandmark() async {
    if (_formKey.currentState!.validate()) {
      // Check if images are selected
      if (_selectedImages.isEmpty) {
        _showError('Please add at least one image');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // Upload all images to GCS
        List<String> uploadedImageUrls = [];
        
        for (int i = 0; i < _selectedImages.length; i++) {
          print('Uploading image ${i + 1} of ${_selectedImages.length}...');
          
          final imageUrl = await _storageService.uploadPicture(_selectedImages[i]);
          
          if (imageUrl != null) {
            uploadedImageUrls.add(imageUrl);
            print('Successfully uploaded: $imageUrl');
            
            // Show progress
            if (mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uploaded ${i + 1} of ${_selectedImages.length} images'),
                  duration: const Duration(milliseconds: 800),
                  backgroundColor: const Color(0xff795548),
                ),
              );
            }
          } else {
            throw Exception('Failed to upload image ${i + 1}');
          }
        }

        // TODO: Save landmark data to your database with the uploaded image URLs
        final landmarkData = {
          'name': _nameController.text,
          'location': _locationController.text,
          'review': _reviewController.text,
          'latitude': _latitudeController.text,
          'longitude': _longitudeController.text,
          'rating': _rating,
          'categories': _selectedCategories,
          'imageUrls': uploadedImageUrls,
        };

        print('Landmark data to save: $landmarkData');
        print('Total images uploaded: ${uploadedImageUrls.length}');

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All ${uploadedImageUrls.length} images uploaded successfully!'),
              backgroundColor: const Color(0xff795548),
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Wait a bit before popping to show the success message
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error during save: $e');
        setState(() {
          _isUploading = false;
        });
        _showError('Failed to upload images: ${e.toString()}');
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
          onPressed: _isUploading ? null : () => Navigator.pop(context),
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
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff795548)),
                ),
              ),
            )
          else
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
      body: AbsorbPointer(
        absorbing: _isUploading,
        child: SingleChildScrollView(
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
                      border: Border.all(color: const Color(0xffd2c2b2), width: 2),
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
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[idx],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
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
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: Color(0xffbca18c),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Add Photos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffbca18c),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap to select multiple images',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xffbca18c),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter landmark name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location field with button
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'Enter location',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.my_location, size: 20),
                        label: const Text('GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff795548),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Latitude and Longitude
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _latitudeController,
                        label: 'Latitude',
                        hint: '0.000000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _longitudeController,
                        label: 'Longitude',
                        hint: '0.000000',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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
                
                const SizedBox(height: 32),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _saveLandmark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff795548),
                      disabledBackgroundColor: const Color(0xff795548).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Uploading Images...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
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
              borderSide: const BorderSide(color: Color(0xffe7dfd8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffe7dfd8)),
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