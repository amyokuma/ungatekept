import 'package:flutter/material.dart';
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
      'description': widget.description ?? 'The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean. Opened in 1937, it has become one of the most internationally recognized symbols of San Francisco and California. The bridge\'s Art Deco design and iconic orange color make it a photographer\'s dream and a must-visit destination for travelers from around the world.',
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
    return Scaffold(
      backgroundColor: const Color(0xfff8f4f3),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 110),
                    
                    // 1. Map Card with Name & Location
                    _buildMapCard(),

                    const SizedBox(height: 20),

                    // 2. Tags
                    _buildTagsSection(),

                    const SizedBox(height: 20),

                    // 3. Rating Card
                    _buildRatingCard(),

                    const SizedBox(height: 20),

                    // 4. Description merged with Quick Info
                    _buildDescriptionWithInfo(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
          
          // Floating action buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f4f3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff41342b), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                // Right side buttons
                Row(
                  children: [
                    // Favorite button
                    Container(
                      decoration: BoxDecoration(
                        color: isFavorited ? const Color(0xff795548) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.white : const Color(0xff41342b),
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorited = !isFavorited;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Share button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Color(0xff41342b), size: 22),
                        onPressed: () {},
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

  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating & Reviews',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating number
              Column(
                children: [
                  Text(
                    '${landmark['rating']}',
                    style: const TextStyle(
                      fontSize: 48,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            landmark['description'] as String,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xff41342b),
            ),
          ),
          
          const SizedBox(height: 24),
          Divider(color: const Color(0xff795548).withOpacity(0.15)),
          const SizedBox(height: 20),
          
          // Quick Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time,
                  'Duration',
                  landmark['visitDuration'] as String,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.wb_sunny,
                  'Best Time',
                  landmark['bestTimeToVisit'] as String,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Divider(color: const Color(0xff795548).withOpacity(0.15)),
          const SizedBox(height: 16),
          
          // Highlights
          const Text(
            'Highlights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff41342b),
            ),
          ),
          const SizedBox(height: 12),
          ...((landmark['highlights'] as List).map((highlight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xff795548),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      highlight,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xff41342b),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
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