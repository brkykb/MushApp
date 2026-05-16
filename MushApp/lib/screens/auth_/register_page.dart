import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mantar/screens/home_page.dart';
import 'package:mantar/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<void> _syncWithBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      await _apiService.firebaseAuth(idToken!);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        await _syncWithBackend();
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Giriş Hatası: $e")));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() { _isLoading = true; });
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        throw Exception("Apple Identity Token alınamadı.");
      }

      final OAuthProvider oauthProvider = OAuthProvider("apple.com");
      final AuthCredential credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _syncWithBackend();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      debugPrint("Apple Register Detail Error: $e");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains("com.apple.AuthenticationServices.AuthorizationError")) {
          errorMsg = "Apple girişi iptal edildi veya bir hata oluştu.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Apple Giriş Hatası: $errorMsg")));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty || _surnameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifreler eşleşmiyor.")));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        // İsim ve Soyismi Firebase profiline ekleyelim
        await credential.user!.updateDisplayName("${_nameController.text.trim()} ${_surnameController.text.trim()}");
        
        await _syncWithBackend();
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Kayıt başarısız oldu.";
      if (e.code == 'weak-password') {
        message = "Şifreniz çok zayıf (En az 6 karakter olmalı).";
      } else if (e.code == 'email-already-in-use') {
        message = "Bu email adresi zaten kullanımda.";
      } else if (e.code == 'invalid-email') {
        message = "Geçersiz email formatı.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bir hata oluştu: $e")));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. ARKA PLAN
          Container(
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?q=80&w=2074&auto=format&fit=crop",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. KARARTMA
          Container(color: Colors.black.withOpacity(0.4)),

          // 3. İÇERİK
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 70,
                    width: 70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Aramıza Katıl",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Doğayı keşfetmek için hesabını oluştur.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            // --- AD VE SOYAD (AYRILDI VE YAN YANA GELDİ) ---
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassTextField(
                                    controller: _nameController,
                                    icon: Icons.person_outline,
                                    hintText: "Ad",
                                  ),
                                ),
                                const SizedBox(width: 12), // Aralarında boşluk
                                Expanded(
                                  child: _buildGlassTextField(
                                    controller: _surnameController,
                                    icon: Icons.person_outline,
                                    hintText: "Soyad",
                                  ),
                                ),
                              ],
                            ),

                            // ---------------------------------------------
                            const SizedBox(height: 16),

                            _buildGlassTextField(
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              hintText: "Email Adresi",
                            ),
                            const SizedBox(height: 16),

                            _buildGlassTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              hintText: "Şifre",
                              isPassword: true,
                              isVisible: _isPasswordVisible,
                              onVisibilityToggle: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildGlassTextField(
                              controller: _confirmPasswordController,
                              icon: Icons.lock,
                              hintText: "Şifre Tekrar",
                              isPassword: true,
                              isVisible: _isConfirmPasswordVisible,
                              onVisibilityToggle: () => setState(
                                () => _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                              ),
                            ),

                            const SizedBox(height: 32),

                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    const Color(0xFF81C784),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        "Hesap Oluştur",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // --- SOSYAL MEDYA (REGISTER'A DA EKLENDİ) ---
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "veya",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  label: "G",
                                  color: Colors.white,
                                  textColor: Colors.red,
                                  onTap: _signInWithGoogle,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  label: "",
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  onTap: _signInWithApple,
                                ),
                              ],
                            ),

                            // ---------------------------------------------
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Zaten hesabın var mı? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // YARDIMCI METODLAR (Kod tekrarını önlemek için)
  Widget _buildSocialButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, // Register'da biraz daha küçük olabilir
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required IconData icon,
    required String hintText,
    TextEditingController? controller,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
