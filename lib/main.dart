import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/cities/screens/cities_list_screen.dart';
import 'package:tripaldashboard/modules/sub_cities/screens/sub_cities_list_screen.dart';
import 'package:tripaldashboard/modules/regions/screens/regions_list_screen.dart';
import 'package:tripaldashboard/modules/areas/screens/areas_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("============ APP INITIALIZATION ============");
  print("1. Loading environment variables...");
  
  try {
    // Initialize Supabase
    print("2. Initializing Supabase...");
    final supabaseClient = await SupabaseService.initialize();
    print("3. Supabase initialized successfully!");
    
    // Check authentication status
    final session = await supabaseClient.auth.currentSession;
    print("4. Current auth session: ${session != null ? 'Active' : 'None'}");
    
    // Check service status
    print("7. Checking Supabase connection...");
    try {
      final healthCheck = await supabaseClient.from('regions').select().limit(1);
      print("8. Database connection successful: ${healthCheck != null ? 'Yes' : 'No'}");
    } catch (e) {
      print("8. ERROR checking database connection: $e");
    }
    
    print("9. Checking storage access...");
    try {
      final buckets = await supabaseClient.storage.listBuckets();
      print("10. Available buckets: ${buckets.map((b) => b.name).join(', ')}");
    } catch (e) {
      print("10. ERROR listing buckets: $e");
    }
    
    print("11. Starting Flutter app...");
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    
  } catch (e) {
    print("Error initializing app: $e");
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }
  
  print("============ INITIALIZATION COMPLETE ============");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripal Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const RegionsListScreen(),
    const CitiesListScreen(),
    const SubCitiesListScreen(),
    const AreasListScreen(),
    const SettingsScreen(),
  ];
  
  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    navigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // This makes sure all items are visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Regions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Cities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.domain),
            label: 'Sub-Cities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Areas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripal Dashboard'),
      ),
      drawer: DrawerMenu(onNavigate: (index) {
        if (dashboardState != null) {
          dashboardState.navigateToTab(index);
        }
      }),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Tripal Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your hotel and activity listings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (dashboardState != null) {
                      dashboardState.navigateToTab(1); // Navigate to Regions
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Regions'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (dashboardState != null) {
                      dashboardState.navigateToTab(2); // Navigate to Cities
                    }
                  },
                  icon: const Icon(Icons.location_city),
                  label: const Text('Cities'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (dashboardState != null) {
                      dashboardState.navigateToTab(3); // Navigate to Sub-Cities
                    }
                  },
                  icon: const Icon(Icons.domain),
                  label: const Text('Sub-Cities'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (dashboardState != null) {
                      dashboardState.navigateToTab(4); // Navigate to Areas
                    }
                  },
                  icon: const Icon(Icons.place),
                  label: const Text('Areas'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (dashboardState != null) {
                  dashboardState.navigateToTab(5); // Navigate to Settings
                }
              },
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: const DrawerMenu(),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            subtitle: Text('Manage your account details'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Configure notification settings'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            subtitle: Text('Change password and security settings'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            subtitle: Text('Get help with using the dashboard'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const DrawerMenu({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tripal Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Manage your business',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Regions'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Cities'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.domain),
            title: const Text('Sub-Cities'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Areas'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text('Accommodations'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to accommodations screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccommodationsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_activity),
            title: const Text('Activities'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to activities screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivitiesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Photos'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to photos screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotosScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              if (onNavigate != null) onNavigate!(5);
            },
          ),
        ],
      ),
    );
  }
}

// Accommodations Screen
class AccommodationsScreen extends StatelessWidget {
  const AccommodationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sheraton Hotel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Luxury hotel in downtown Addis Ababa'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rooms: 25'),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hilton Hotel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Business hotel with conference facilities'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rooms: 18'),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new accommodation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Activities Screen
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lake Tana Boat Tour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Guided tour of the lake monasteries'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration: 3 hours'),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'City Walking Tour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Explore the historic parts of Addis Ababa'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration: 2 hours'),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new activity
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Photos Screen
class PhotosScreen extends StatelessWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Management'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Text(
                      'Photo ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new photos
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
