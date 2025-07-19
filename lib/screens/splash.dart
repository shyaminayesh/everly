import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glareController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glareAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glareController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _glareAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _glareController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      _glareController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_animationController, _glareController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Stack(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.9),
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.8),
                          ],
                          stops: [
                            0.0,
                            _glareAnimation.value - 0.3,
                            _glareAnimation.value,
                            _glareAnimation.value + 0.3,
                            1.0,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Everly',
                        style: GoogleFonts.dancingScript(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
