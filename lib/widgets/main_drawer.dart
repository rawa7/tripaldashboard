import 'package:flutter/material.dart';
import '../screens/accommodations/accommodations_screen.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/photos/photos_screen.dart';
import '../screens/regions/regions_screen.dart';
import '../screens/cities/cities_screen.dart';
import '../screens/providers/providers_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).primaryColor,
            child: const Text(
              'Tripal Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildDrawerItem(
            context, 
            'Accommodations', 
            Icons.hotel,
            () => _navigateTo(context, const AccommodationsScreen()),
          ),
          _buildDrawerItem(
            context, 
            'Activities', 
            Icons.local_activity,
            () => _navigateTo(context, const ActivitiesScreen()),
          ),
          _buildDrawerItem(
            context, 
            'Photos', 
            Icons.photo_library,
            () => _navigateTo(context, const PhotosScreen()),
          ),
          const Divider(),
          _buildDrawerItem(
            context, 
            'Regions', 
            Icons.map,
            () => _navigateTo(context, const RegionsScreen()),
          ),
          _buildDrawerItem(
            context, 
            'Cities', 
            Icons.location_city,
            () => _navigateTo(context, const CitiesScreen()),
          ),
          _buildDrawerItem(
            context, 
            'Providers', 
            Icons.business,
            () => _navigateTo(context, const ProvidersScreen()),
          ),
          _buildDrawerItem(
            context, 
            'Bookings', 
            Icons.book_online,
            () => _navigateTo(context, const BookingsScreen()),
          ),
          const Divider(),
          _buildDrawerItem(
            context, 
            'Settings', 
            Icons.settings,
            () => _navigateTo(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // Close the drawer
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => screen),
    );
  }
} 