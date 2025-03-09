import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/regions/screens/regions_list_screen.dart';

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripal Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
            ElevatedButton.icon(
              onPressed: () {
                if (dashboardState != null) {
                  dashboardState.navigateToTab(1);
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Manage Regions'),
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
