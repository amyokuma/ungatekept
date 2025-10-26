import 'package:flutter/material.dart';
import 'package:Loaf/screens/landmark_details_page.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final List<String>? tags;
  final VoidCallback? onTap;

  const LocationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.tags,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayTags = tags ?? ['chill', 'indoors', 'outdoors', 'cozy', 'scenic'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 14 / 11,
            child: GestureDetector(
              onTap: onTap ?? () {
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
                  stops: const [0, 1.0],
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                  Row(
                    children: displayTags.map((tag) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )).toList(),
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
