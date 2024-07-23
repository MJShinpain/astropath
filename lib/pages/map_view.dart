import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/city_data.dart';

class MapView extends StatelessWidget {
  final List<Map<String, dynamic>> cities;

  const MapView({Key? key, required this.cities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return SizedBox.shrink();

    return Container(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(0, 0),
          initialZoom: 1,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: cities.asMap().entries.map((entry) {
              int idx = entry.key + 1;
              var cityInfo = entry.value;
              City city = cityInfo['city'];
              return Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(city.latitude, city.longitude),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$idx',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}