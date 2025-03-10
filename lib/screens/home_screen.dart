import 'package:flutter/material.dart';
import 'package:tripaldashboard/main.dart';
import '../modules/activities/screens/activities_screen.dart';
import '../modules/photos/screens/photos_screen.dart';
import '../widgets/main_drawer.dart';
import '../screens/accommodations/accommodations_screen.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/photos/photos_screen.dart';
import '../screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardHome(),
    const AccommodationsScreen(),
    const ActivitiesScreen(),
    const PhotosScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripal Dashboard'),
      ),
      drawer: const MainDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Accommodations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Photos',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildNavCard(
          context,
          'Accommodations',
          Icons.hotel,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccommodationsScreen(),
            ),
          ),
        ),
        _buildNavCard(
          context,
          'Activities',
          Icons.local_activity,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ActivitiesScreen(),
            ),
          ),
        ),
        _buildNavCard(
          context,
          'Photos',
          Icons.photo_library,
          Colors.amber,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PhotosScreen(),
            ),
          ),
        ),
        _buildNavCard(
          context,
          'Settings',
          Icons.settings,
          Colors.grey,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, 
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 