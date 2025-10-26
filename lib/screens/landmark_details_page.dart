import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Loaf/config/api_keys.dart';


class LandmarkDetailPage extends StatefulWidget {
  final String? name;
  final String? location;
  final String? imageUrl;
  final String? description;
  final double? latitude;
  final double? longitude;
  
  const LandmarkDetailPage({
    Key? key,
    this.name,
    this.location,
    this.imageUrl,
    this.description,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<LandmarkDetailPage> createState() => _LandmarkDetailPageState();
}

class _LandmarkDetailPageState extends State<LandmarkDetailPage> {
  // Simulate user review state
  bool hasUserReviewed = false;
  double? userRating;
  String? userReviewText;
  List<String> userReviewPhotos = [];
  bool isFavorited = false;

  // Use passed data or fallback to sample data
  late final Map<String, dynamic> landmark;

  @override
  void initState() {
    super.initState();
    landmark = {
      'name': widget.name ?? 'Golden Gate Bridge',
      'location': widget.location ?? 'San Francisco, CA',
      'mainImage': widget.imageUrl ?? 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=1200&h=600&fit=crop',
      'latitude': widget.latitude ?? 37.8199,
      'longitude': widget.longitude ?? -122.4783,
      'rating': 4.8,
      'totalReviews': 15234,
      'description': widget.description ?? 'The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean. Opened in 1937, it has become one of the most internationally recognized symbols of San Francisco and California. The bridge\'s Art Deco design and iconic orange color make it a photographer\'s dream and a must-visit destination for travelers from around the world.\n\nWhether you\'re walking, biking, or simply admiring the view from afar, the Golden Gate Bridge offers breathtaking vistas and a sense of awe-inspiring scale. Its construction was a remarkable feat of engineering, and today it stands as a testament to human ingenuity and vision. Visitors can enjoy panoramic views of the bay, Alcatraz Island, and the city skyline, especially during sunrise and sunset when the light paints the bridge in stunning hues.',
      'visitDuration': '1-2 hours',
      'bestTimeToVisit': 'Early morning or sunset',
      'category': 'Architectural Marvel',
      'yearBuilt': 1937,
      'highlights': [
        'Iconic orange towers rising 746 feet',
        'Stunning views of San Francisco Bay',
        'Walking and biking paths available',
        'Historic engineering feat'
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final latitude = landmark['latitude'] as double;
    final longitude = landmark['longitude'] as double;
    final name = landmark['name'] as String;
    final location = landmark['location'] as String;
    final String mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=15'
        '&size=800x600'
        '&scale=2'
        '&markers=color:red|$latitude,$longitude'
        '&style=feature:poi|visibility:off'
        '&key=${ApiKeys.googleMapsAPIKey}';

    return Scaffold(
      backgroundColor: const Color(0xfff8f4f3),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map (scrolls away with content) with overlayed title/location
                    SizedBox(
                      width: double.infinity,
                      height: 320,
                      child: Stack(
                        children: [
                          Image.network(
                            mapUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 320,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 320,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF9333EA),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 320,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.map_outlined, size: 56, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Map unavailable',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Beige overlay for readability
                          Container(
                            width: double.infinity,
                            height: 320,
                            color: const Color(0xfff8f4f3).withOpacity(0.75),
                          ),
                          // Title and location overlayed on top of map
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff41342b),
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xff795548), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff795548),
                                          shadows: [
                                            Shadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 2. Tags
                    _buildTagsSection(),
                    const SizedBox(height: 20),
                    // 3. Description (moved above rating)
                    _buildDescriptionWithInfo(),
                    const SizedBox(height: 20),
                    // 4. Rating Card
                    _buildRatingCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
          // Floating action buttons (unchanged)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (no circle background)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff41342b), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                // Right side buttons (no circle background)
                Row(
                  children: [
                    // Bookmark button
                    IconButton(
                      icon: Icon(
                        isFavorited ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorited ? const Color(0xff795548) : const Color(0xff41342b),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorited = !isFavorited;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    // Share button
                    IconButton(
                      icon: const Icon(Icons.share, color: Color(0xff41342b), size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    // Example user rating (replace with real user data if available)
  // If user has reviewed, show their rating; else null
  // (displayUserRating was unused, removed)
    // Example reviews list (replace with real data)
    final List<Map<String, dynamic>> reviews = [
      {
        'user': 'Alice',
        'rating': 5.0,
        'text': 'Absolutely stunning! A must-see in SF.',
        'photos': [
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=200',
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=200',
        ],
      },
      {
        'user': 'Bob',
        'rating': 4.5,
        'text': 'Great views, but can get crowded.',
        'photos': [
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=200',
        ],
      },
      {
        'user': 'Charlie',
        'rating': 4.0,
        'text': 'Loved walking across the bridge at sunset.',
        'photos': [],
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ratings & Reviews',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 20),
          // Your Rating or Add Review Button
          if (!hasUserReviewed) ...[
            ElevatedButton.icon(
              onPressed: () async {
                double tempRating = 0;
                TextEditingController reviewController = TextEditingController();
                List<String> photoPaths = [];
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                              minWidth: 320,
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Your Rating:', style: TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return IconButton(
                                              icon: Icon(
                                                tempRating >= index + 1
                                                    ? Icons.star
                                                    : (tempRating >= index + 0.5 ? Icons.star_half : Icons.star_border),
                                                color: Colors.amber,
                                                size: 32,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  tempRating = index + 1.0;
                                                });
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  tempRating = index + 0.5;
                                                });
                                              },
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Your Review:', style: TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: reviewController,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            hintText: 'Share your experience...',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Add Photos:', style: TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                final picked = await ImagePicker().pickMultiImage();
                                                if (picked.isNotEmpty) {
                                                  setState(() {
                                                    photoPaths.addAll(picked.map((x) => x.path));
                                                  });
                                                }
                                              },
                                              icon: const Icon(Icons.add_a_photo, color: Color(0xff795548)),
                                              label: const Text('Upload'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xfff8f4f3),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  side: const BorderSide(color: Color(0xff795548)),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (photoPaths.isNotEmpty)
                                              Expanded(
                                                child: SizedBox(
                                                  height: 50,
                                                  child: ListView.separated(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: photoPaths.length,
                                                    separatorBuilder: (context, idx) => const SizedBox(width: 8),
                                                    itemBuilder: (context, idx) {
                                                      return Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(8),
                                                            child: Image.file(
                                                              File(photoPaths[idx]),
                                                              width: 50,
                                                              height: 50,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  photoPaths.removeAt(idx);
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black54,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                if (tempRating > 0 && reviewController.text.trim().isNotEmpty) {
                                                  setState(() {
                                                    userRating = tempRating;
                                                    userReviewText = reviewController.text.trim();
                                                    userReviewPhotos = List<String>.from(photoPaths);
                                                    hasUserReviewed = true;
                                                  });
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Review posted!')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Please provide a rating and review.')),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xff795548),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text('Post Review', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // X button to close
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
                setState(() {}); // Refresh after dialog
              },
              icon: const Icon(Icons.rate_review, color: Color(0xff795548)),
              label: const Text('Add Review', style: TextStyle(color: Color(0xff795548))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff8f4f3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xff795548)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff41342b),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (userRating ?? 0).floor()
                        ? Icons.star
                        : (index < (userRating ?? 0) ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 28,
                  );
                }),
                const SizedBox(width: 10),
                Text(
                  (userRating ?? 0).toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff41342b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (userReviewText != null && userReviewText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  userReviewText!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            if (userReviewPhotos.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: userReviewPhotos.length,
                  separatorBuilder: (context, idx) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(userReviewPhotos[idx]),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
          // Overall Rating
          const Text(
            'Overall Rating',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating number
              Column(
                children: [
                  Text(
                    '${landmark['rating']}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff41342b),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (landmark['rating'] as double).floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(landmark['totalReviews'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} reviews',
                    style: const TextStyle(
                      color: Color(0xff795548),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Rating bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.75),
                    _buildRatingBar(4, 0.18),
                    _buildRatingBar(3, 0.05),
                    _buildRatingBar(2, 0.02),
                    _buildRatingBar(1, 0.01),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Reviews List
          const Text(
            'All Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (int index = 0; index < reviews.length; index++) ...[
                if (index != 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Text(reviews[index]['user'][0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                reviews[index]['user'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff41342b),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...List.generate(5, (star) {
                                return Icon(
                                  star < (reviews[index]['rating'] as double).floor()
                                      ? Icons.star
                                      : (star < reviews[index]['rating'] ? Icons.star_half : Icons.star_border),
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reviews[index]['text'],
                            style: const TextStyle(fontSize: 15),
                          ),
                          if (reviews[index]['photos'] != null && (reviews[index]['photos'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: (reviews[index]['photos'] as List).length,
                                separatorBuilder: (context, idx) => const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final photoUrl = reviews[index]['photos'][idx];
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: GestureDetector(
                                            onTap: () => Navigator.of(context).pop(),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(
                                                photoUrl,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        photoUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$stars★',
              style: const TextStyle(fontSize: 12, color: Color(0xff795548)),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xfff8f4f3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff795548),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: Color(0xff795548)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    // You can customize these tags based on landmark data
    final tags = [
      landmark['category'] as String,
      landmark['bestTimeToVisit'] as String,
      '${landmark['yearBuilt']}',
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff795548),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionWithInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Title
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            landmark['description'] as String,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xff41342b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xff795548), size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff795548),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff41342b),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard() {
    final latitude = landmark['latitude'] as double;
    final longitude = landmark['longitude'] as double;
    final name = landmark['name'] as String;
    final location = landmark['location'] as String;
    
    // Google Maps Static API URL
    final String mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=15'
        '&size=600x400'
        '&scale=2'
        '&markers=color:red|$latitude,$longitude'
        '&style=feature:poi|visibility:off'
        '&key=${ApiKeys.googleMapsAPIKey}';  
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Image - Larger and more prominent
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                Image.network(
                  mapUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Map unavailable',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Gradient overlay at bottom for better text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Directions button overlay
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff795548),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.directions, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Get Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Name and Location below the map
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff41342b),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xff795548), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff795548),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}