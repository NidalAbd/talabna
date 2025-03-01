import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final Language language = Language();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    language.getLanguage();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        final isDark = theme.brightness == Brightness.dark;

        return Scaffold(
          body: Stack(
            children: [
              // Logo title background
              LogoTitle(
                fontSize: 40,
                playAnimation: false,
                logoSize: 60,
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Settings buttons row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white38,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.language),
                              tooltip: 'Change Language',
                              onPressed: () {
                                Navigator.pushNamed(context, '/language');
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white38,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                              tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                              onPressed: () => BlocProvider.of<ThemeCubit>(context).toggleTheme(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            // Space for logo (since logo is in a stack)
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                            // Main content area
                            Expanded(
                              child: FadeTransition(
                                opacity: _fadeInAnimation,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      // Illustration
                                      Container(
                                        height: size.height * 0.3,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark ? Colors.black12 : Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24),
                                          child: const Image(
                                            image: AssetImage('assets/welcomeInfo.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 24),

                                      // Headline text
                                      Text(
                                        'Discover What We Offer',
                                        style: GoogleFonts.cairo(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: isDark ? Colors.white : Color(0xFF2D3748),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      SizedBox(height: 12),

                                      // Subheadline text
                                      Text(
                                        'Experience our premium services designed to meet your needs.',
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          color: isDark ? Colors.white70 : Color(0xFF718096),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Buttons section
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0, top: 12.0),
                                child: Column(
                                  children: [
                                    // Sign up button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(context, '/register');
                                        },
                                        child: Text(
                                          language.signUpText(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 12),

                                    // Login button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(context, '/login');
                                        },
                                        child: Text(
                                          language.loginText(),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}