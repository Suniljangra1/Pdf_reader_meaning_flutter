import 'package:flutter/material.dart';
import 'views/home/home_screen.dart';
import 'views/history/history_screen.dart';
import 'views/contact/contact_screen.dart';
import 'views/support/support_screen.dart';
import 'views/downloaded/downloaded_screen.dart';
import 'utils/colors.dart';

void main() {
  runApp(const PDFDictionaryApp());
}

class PDFDictionaryApp extends StatelessWidget {
  const PDFDictionaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Dictionary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    DownloadedScreen(),
    ContactScreen(),
    SupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloaded'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Contact'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Support'),
        ],
      ),
    );
  }
}