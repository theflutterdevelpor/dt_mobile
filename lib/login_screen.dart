import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dt_mobile/bottom_nav_bar/home_nav_bar.dart';
import 'package:dt_mobile/models/request/login_request.dart';
import 'package:dt_mobile/models/response/login_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool rememberMe = false;
  int _currentCarouselIndex = 0;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> imgList = [
    'assets/images/login1.png',
    'assets/images/login2.png',
    'assets/images/login3.png',
  ];


  final String baseUrl = 'http://3.231.62.206:5000/api/v1';

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }


  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString('remembered_email');
    if (rememberedEmail != null) {
      setState(() {
        emailController.text = rememberedEmail;
        rememberMe = true;
      });
    }
  }


  Future<void> _handleLogin() async {

    if (emailController.text.isEmpty) {
      _showError('Email is required');
      return;
    }
    if (passwordController.text.isEmpty) {
      _showError('Password is required');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final loginRequest = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        print("API hit successful!");
        print("Response: ${response.body}");
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        if (loginResponse.success && loginResponse.data != null) {
          final token = loginResponse.data!.token;
          final userId = loginResponse.data!.userId;
          final userName = loginResponse.data!.name;
          final userEmail = loginResponse.data!.email;
          final userRole = loginResponse.data!.role;
          final orgId = loginResponse.data!.organizationId;
          final orgName = loginResponse.data!.organizationName;


          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('user_id', userId);
          await prefs.setString('user_name', userName);
          await prefs.setString('user_email', userEmail);
          await prefs.setString('user_role', userRole);
          await prefs.setString('organization_id', orgId);
          await prefs.setString('organization_name', orgName);


          if (rememberMe) {
            await prefs.setString('remembered_email', emailController.text.trim());
          } else {
            await prefs.remove('remembered_email');
          }

          if (!mounted) return;


          _showSuccess('Login successful');


          // await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          if (!mounted) return;
          _showError(loginResponse.message ?? 'Login failed');
        }
      } else {
        _showError('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;


    final double cardWidth = screenWidth > 420 ? 400 : screenWidth * 0.92;
    final double fieldWidth = cardWidth - 48;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: screenHeight,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
            items: imgList.map((item) => Image.asset(
              item,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )).toList(),
          ),

          // Dark Overlay
          Container(color: Colors.black.withValues(alpha: 0.3)),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: (screenWidth - cardWidth) / 2,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 130,
                      width: 150,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Tagline
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Building the Future.....',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),


                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Revolutionize building management with our AI-powered Digital Twin. Monitor, control, and optimize every sensor and device in real-time through an interactive 3D model. Gain energy insights, predictive maintenance alerts, and centralized automation—all in one intelligent platform. Unlock efficiency, reduce downtime, and transform operations with next-gen smart infrastructure.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(
                        imgList.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentCarouselIndex == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentCarouselIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Material(
                      elevation: 20,
                      borderRadius: BorderRadius.circular(20),
                      shadowColor: Colors.black54,
                      child: Container(
                        width: cardWidth,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WELCOME BACK',
                                style: TextStyle(fontSize: 12, color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            const Text('Log In to your Account',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            TextField(
                              controller: emailController,
                              cursorColor: Colors.green,
                              enableInteractiveSelection: false,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                                hintText: "johnsondoe@nomail.com",
                                hintStyle: const TextStyle(color: Colors.black54),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.3)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.green, width: 2)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),

                            // Password Field
                            TextField(
                              controller: passwordController,
                              cursorColor: Colors.green,
                              enableInteractiveSelection: false,
                              enabled: !isLoading,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                                hintText: "Enter your password",
                                hintStyle: const TextStyle(color: Colors.black54),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.3)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Colors.green, width: 2)),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Remember me + Forgot
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(value: rememberMe,
                                        activeColor: Colors.green,
                                        onChanged: (v) =>
                                            setState(() => rememberMe = v ?? false)),
                                    const Text('Remember me',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: !isLoading ? () {} : null,
                                  child: const Text('Forgot Password?',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text("CONTINUE",
                                    style: TextStyle(fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

