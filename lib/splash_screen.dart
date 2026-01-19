import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers - ma nage the timing and state of each animation
  late AnimationController _carController;           // Controls motor sliding icon
  late AnimationController _rotationController;      // Controls car rotation (drift effect)
  late AnimationController _smokeController;         // Controls smoke particle effects
  late AnimationController _textController;          // Controls text appearance
  late AnimationController _wrenchController;        // Controls wrench spinning

  // Animation objects - define how properties change over time
  late Animation<Offset> _carSlideAnimation;         // Car position from right to center
  late Animation<double> _carRotationAnimation;      // Car angle during drift
  late Animation<double> _smokeFadeAnimation;        // Smoke opacity
  late Animation<double> _textFadeAnimation;         // Text opacity
  late Animation<double> _textScaleAnimation;        // Text size (zoom effect)
  late Animation<double> _wrenchRotationAnimation;   // Wrench rotation angle

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with durations
    _carController = AnimationController(
      duration: const Duration(milliseconds: 1800), //the time of the animation
      vsync: this, //"Vertical Sync" it's a synchronization mechanism that ties animations to the screen's refresh rate.
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _smokeController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _wrenchController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Car slides from off-screen right (3.0) to center (0.0)
    // Offset(3.0, 0.0) means 3x screen width to the right
    _carSlideAnimation = Tween<Offset>(
      begin: const Offset(3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _carController,
      curve: Curves.easeOutCubic,  // Smooth deceleration
    ));

    // Car rotates in two stages: drift hard then settle
    // -0.4 radians = ~23 degrees tilt (drift angle)
    // -0.15 radians = ~8 degrees (final settled position)
    _carRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,  // First half of animation
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.4, end: -0.15)
            .chain(CurveTween(curve: Curves.elasticOut)),  // Bouncy settle
        weight: 50,  // Second half of animation
      ),
    ]).animate(_rotationController);

    // Smoke appears (0.0 to 0.7) then disappears (0.7 to 0.0) [Fade in out effect]
    _smokeFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.7),
        weight: 30,  // Fade in quickly (30% of time)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 0.0),
        weight: 70,  // Fade out slowly (70% of time)
      ),
    ]).animate(_smokeController);

    // Text fades in starting at 30% of the animation duration
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Text scales from 50% to 100% size with elastic bounce
    _textScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.elasticOut,  // Bouncy zoom effect
      ),
    );

    // Wrench spins 360 degrees (2 * π radians = full circle)
    _wrenchRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _wrenchController,
        curve: Curves.easeInOut,
      ),
    );

    // Start all animations in sequence
    _startAnimationSequence();

    // Navigate to authentication screen after 3.8 seconds
    Timer(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  // Orchestrates the timing of all animations
  void _startAnimationSequence() async {
    // Start car drift and smoke effects immediately
    _carController.forward();
    _rotationController.forward();
    _smokeController.forward();

    // Wait 1.2 seconds, then show text and start wrench spinning
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();
    _wrenchController.repeat();  // Repeat indefinitely
  }

  @override
  void dispose() {
    // Clean up animation controllers to prevent memory leaks
    _carController.dispose();
    _rotationController.dispose();
    _smokeController.dispose();
    _textController.dispose();
    _wrenchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dark gradient background for racing/street vibe
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a1a),  // Dark gray at top
              const Color(0xFF2d2d2d),  // Medium gray in middle
              const Color(0xFFFF8C00).withOpacity(0.3),  // Orange glow at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // ANIMATED ROAD LINES - Create moving road effect
            // Generate 8 horizontal lines that move down as car enters
            ...List.generate(8, (index) {
              return AnimatedBuilder(
                animation: _carController,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    // Lines move upward as animation progresses
                    top: 100.0 + (index * 80.0) - (_carController.value * 200),
                    child: Container(
                      height: 2,
                      // Lines fade out as car arrives
                      color: Colors.white.withOpacity(0.1 * (1 - _carController.value)),
                    ),
                  );
                },
              );
            }),

            // SMOKE PARTICLE EFFECTS - Create drift smoke behind car
            // Generate 5 smoke circles with different sizes and positions
            ...List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _smokeFadeAnimation,
                builder: (context, child) {
                  return Positioned(
                    // Spread smoke particles horizontally
                    right: MediaQuery.of(context).size.width * 0.3 + (index * 40.0),
                    // Spread smoke particles vertically
                    top: MediaQuery.of(context).size.height * 0.35 + (index * 15.0),
                    child: Opacity(
                      // Each particle fades differently (further particles fade faster)
                      opacity: _smokeFadeAnimation.value * (1 - index * 0.15),
                      child: Container(
                        // Each particle gets progressively larger
                        width: 60.0 + (index * 20.0),
                        height: 60.0 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // DRIFTING CAR - Main animated element
            Center(
              child: SlideTransition(
                position: _carSlideAnimation,  // Slide from right to center
                child: AnimatedBuilder(
                  animation: _carRotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _carRotationAnimation.value,  // Rotate for drift effect
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          // Orange glow around car
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8C00).withOpacity(0.6),
                              spreadRadius: 8,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Car icon
                            const Icon(
                              Icons.directions_car,
                              size: 100,
                              color: Color(0xFFFF8C00),
                            ),
                            // SPINNING WRENCH - Service indicator
                            Positioned(
                              bottom: 50,
                              right: 40,
                              child: AnimatedBuilder(
                                animation: _wrenchRotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _wrenchRotationAnimation.value,  // Continuous spin
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.build,
                                        size: 28,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // APP BRANDING TEXT - Title and tagline
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.25,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: ScaleTransition(
                  scale: _textScaleAnimation,
                  child: Column(
                    children: [
                      // MAIN TITLE with glow effect
                      Stack(
                        children: [
                          // Outer glow layer (stroke)
                          Text(
                            'YallaFix',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 8
                                ..color = const Color(0xFFFF8C00).withOpacity(0.5),
                              letterSpacing: 3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Main text layer (fill)
                          const Text(
                            'YallaFix',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFF8C00),
                                  offset: Offset(0, 5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      const Text(
                        '⚡ DRIFT INTO SERVICE ⚡',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // LOADING INDICATOR - Shows app is loading
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF8C00),
                    ),
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}