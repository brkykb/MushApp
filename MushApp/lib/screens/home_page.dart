import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mantar/providers/mushroom_provider.dart';
import 'package:mantar/screens/home_screen.dart';
import 'package:mantar/screens/map_screen.dart';
import 'package:mantar/screens/wiki_screen.dart';
import 'package:mantar/screens/shop_screen.dart';
import 'package:mantar/screens/profile_screen.dart';
import 'package:mantar/screens/scanner_page.dart';
import 'package:mantar/theme/mush_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MushroomProvider>().fetchUserProfile();
      context.read<MushroomProvider>().fetchHistory();
    });
  }

  final List<Widget> _pages = [
    const MushHomeScreen(), // 0: Ana Sayfa
    const MushMapScreen(),  // 1: Harita
    const ScannerPage(),    // 2: Kamera
    const MushWikiScreen(), // 3: Ansiklopedi (Wiki)
    const MushProfileScreen(), // 4: Profil
    const MushShopScreen(), // 5: Mağaza (Üst bardan açılır)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true, // İçeriğin AppBar'ın arkasına geçmesi için
      
      // --- MODERN ÜST PANEL (APPBAR) ---
      appBar: AppBar(
        automaticallyImplyLeading: false, // Gizli sol ikonları iptal et (Overflow hatasını çözer)
        titleSpacing: 20, // Soldan hafif boşluk
        backgroundColor: Colors.transparent, // Şeffaf arka plan
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text(
              "MushApp",
              style: TextStyle(
                color: MushTheme.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // COIN BAKİYESİ
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MushTheme.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: MushTheme.coinGold, size: 20),
                const SizedBox(width: 6),
                Text(
                  context.watch<MushroomProvider>().userProfile?['money']?.toString() ?? "0",
                  style: const TextStyle(
                    color: MushTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // MAĞAZA İKONU (Hızlı Erişim)
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: MushTheme.primaryGreen),
            onPressed: () => _onItemTapped(5), // Shop sekmesine götürür (Index 5)
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      // --- MERKEZDEKİ TARAYICI BUTONU ---
      floatingActionButton: Container(
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: MushTheme.surfaceCream, width: 4),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerPage()),
            );
          },
          backgroundColor: MushTheme.primaryGreen,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt_rounded, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- PREMIUM ALT NAVİGASYON BAR ---
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 80,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(icon: Icons.home_filled, index: 0, label: "Home"),
            _buildNavItem(icon: Icons.map_rounded, index: 1, label: "Map"),
            const SizedBox(width: 60), // Boşluk (Kamera butonu için)
            _buildNavItem(icon: Icons.menu_book_rounded, index: 3, label: "Wiki"),
            _buildNavItem(icon: Icons.person_rounded, index: 4, label: "Profile"),
          ],
        ),
      ),
      
      // Yan menü (Drawer) artık yeni tasarımda pek yer almıyor ama kalsın dersen ekleyebiliriz
      // drawer: ... 
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? MushTheme.primaryGreen : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? MushTheme.primaryGreen : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
