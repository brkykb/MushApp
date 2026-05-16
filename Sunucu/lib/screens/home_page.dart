import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'map_page.dart';
import 'wiki_page.dart';
import 'history_page.dart';
import 'scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Sayfa Listesini Alt Bar Sırasına Göre Güncelledim
  final List<Widget> _pages = [
    const DiscoverPage(), // 0: Ana Sayfa
    const HaritaSayfasi(), // 1: Harita (Soldaki ikinci ikon)
    const ScannerPage(), // 2: KAMERA (Ortadaki Yeşil Buton)
    const HistoryPage(), // 3: Geçmiş
    const WikiPage(), // 4: Kitaplık (Wiki)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APP BAR ---
      appBar: AppBar(
        // title: Text("Mantar Rehberi"), // İstersen başlık açabilirsin
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              print("Çıkış Yapıldı");
            },
          ),
        ],
      ),

      // --- DRAWER (YAN MENÜ) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, // Mantar Yeşili
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mantar Rehberi",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Hoşgeldiniz",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Ana Sayfa"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Ayarlar"),
              onTap: () {},
            ),
          ],
        ),
      ),

      // --- GÖVDE ---
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // --- ORTADAKİ YEŞİL BUTON (SCANNER) ---
      floatingActionButton: SizedBox(
        height: 70, // Butonun büyüklüğü
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            // Ortadaki butona basınca Scanner (Index 2) açılsın
            _onItemTapped(2);
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          shape: const CircleBorder(), // Tam yuvarlak
          child: Icon(
            Icons.travel_explore,
            size: 35,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),

      // Butonu alt barın ortasına göm
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- ALT BAR (YENİ TASARIM) ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Ortadaki oyuk
        notchMargin: 8.0, // Buton ile bar arasındaki boşluk
        color: Theme.of(context).colorScheme.surface,
        elevation: 10,
        height: 65,
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
        ), // Kenar boşluklarını sıfırla

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Eşit dağıt
          children: [
            // SOL TARAFTAKİ İKONLAR
            _buildNavItem(
              icon: Icons.home_rounded,
              index: 0,
              label: "Ana Sayfa",
            ),
            _buildNavItem(icon: Icons.map_rounded, index: 1, label: "Harita"),

            // ORTA BOŞLUK (Buraya buton gelecek)
            const SizedBox(width: 40),

            // SAĞ TARAFTAKİ İKONLAR
            _buildNavItem(
              icon: Icons.history_rounded,
              index: 3,
              label: "Geçmiş",
            ),
            _buildNavItem(
              icon: Icons.auto_stories_rounded,
              index: 4,
              label: "Kitaplık",
            ),
          ],
        ),
      ),
    );
  }

  // Kod tekrarını önlemek için yardımcı fonksiyon
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return IconButton(
      onPressed: () => _onItemTapped(index),
      tooltip: label,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // İkonun taşmasını engeller
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
            size: 28,
          ),
          // Seçili ise altına minik nokta koy (Şık durur)
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
