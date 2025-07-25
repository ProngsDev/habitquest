import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/enhanced_animation_utils.dart';
import '../../widgets/effects/glassmorphism_widget.dart';
import '../home/home_screen.dart';

/// Beautiful splash screen with glassmorphism effects and smooth animations
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _taglineController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Individual controllers for staggered animations
    _logoController = AnimationController(
      duration: EnhancedAnimationUtils.slowDuration,
      vsync: this,
    );

    _titleController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _taglineController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Title animations
    _titleFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    // Tagline animations
    _taglineFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Background animation
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Start background animation immediately
    unawaited(_backgroundController.forward());

    // Staggered animation sequence
    await Future<void>.delayed(const Duration(milliseconds: 300));
    unawaited(_logoController.forward());

    await Future<void>.delayed(const Duration(milliseconds: 400));
    unawaited(_titleController.forward());

    await Future<void>.delayed(const Duration(milliseconds: 200));
    unawaited(_taglineController.forward());

    // Wait for animations to complete, then navigate
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute<void>(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _taglineController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return CupertinoPageScaffold(
      child: DecoratedBox(
        decoration: _buildBackgroundDecoration(isDark),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements
              _buildAnimatedBackground(isDark),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo section
                    _buildLogoSection(isDark),

                    const SizedBox(height: 32),

                    // Title section
                    _buildTitleSection(isDark),

                    const SizedBox(height: 16),

                    // Tagline section
                    _buildTaglineSection(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(bool isDark) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1C1C1E),
              const Color(0xFF2C2C2E),
              const Color(0xFF3A3A3C),
            ]
          : [
              const Color(0xFFF2F2F7),
              const Color(0xFFFFFFFF),
              const Color(0xFFF2F2F7),
            ],
    ),
  );

  Widget _buildAnimatedBackground(bool isDark) => AnimatedBuilder(
    animation: _backgroundAnimation,
    builder: (context, child) => Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPainter(
          progress: _backgroundAnimation.value,
          isDark: isDark,
        ),
      ),
    ),
  );

  Widget _buildLogoSection(bool isDark) => AnimatedBuilder(
    animation: Listenable.merge([_logoScaleAnimation, _logoFadeAnimation]),
    builder: (context, child) => Transform.scale(
      scale: _logoScaleAnimation.value,
      child: Opacity(
        opacity: _logoFadeAnimation.value,
        child: GlassmorphismCard(
          padding: const EdgeInsets.all(24),
          blurIntensity: 15,
          opacity: 0.9,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.checkmark_seal_fill,
              size: 40,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildTitleSection(bool isDark) => AnimatedBuilder(
    animation: Listenable.merge([_titleFadeAnimation, _titleSlideAnimation]),
    builder: (context, child) => SlideTransition(
      position: _titleSlideAnimation,
      child: FadeTransition(
        opacity: _titleFadeAnimation,
        child: GlassmorphismWidget(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          blurIntensity: 12,
          borderRadius: BorderRadius.circular(16),
          child: Text(
            'HabitQuest',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildTaglineSection(bool isDark) => AnimatedBuilder(
    animation: Listenable.merge([
      _taglineFadeAnimation,
      _taglineSlideAnimation,
    ]),
    builder: (context, child) => SlideTransition(
      position: _taglineSlideAnimation,
      child: FadeTransition(
        opacity: _taglineFadeAnimation,
        child: Text(
          'Build Better Habits, Build Better Life',
          style: AppTheme.bodyLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

/// Custom painter for animated background effects
class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.progress, required this.isDark});
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw animated circles
    _drawAnimatedCircles(canvas, size, paint);

    // Draw floating particles
    _drawFloatingParticles(canvas, size, paint);
  }

  void _drawAnimatedCircles(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Large background circle
    paint.color = isDark
        ? AppTheme.primaryBlue.withValues(alpha: 0.1 * progress)
        : AppTheme.primaryBlue.withValues(alpha: 0.05 * progress);

    final radius1 = (size.width * 0.8) * progress;
    canvas.drawCircle(Offset(centerX, centerY), radius1, paint);

    // Medium circle
    paint.color = isDark
        ? AppTheme.primaryPurple.withValues(alpha: 0.08 * progress)
        : AppTheme.primaryPurple.withValues(alpha: 0.04 * progress);

    final radius2 = (size.width * 0.5) * progress;
    canvas.drawCircle(Offset(centerX + 50, centerY - 100), radius2, paint);

    // Small accent circle
    paint.color = isDark
        ? AppTheme.primaryGreen.withValues(alpha: 0.06 * progress)
        : AppTheme.primaryGreen.withValues(alpha: 0.03 * progress);

    final radius3 = (size.width * 0.3) * progress;
    canvas.drawCircle(Offset(centerX - 80, centerY + 120), radius3, paint);
  }

  void _drawFloatingParticles(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42); // Fixed seed for consistent animation

    paint.color = isDark
        ? CupertinoColors.white.withValues(alpha: 0.1 * progress)
        : CupertinoColors.black.withValues(alpha: 0.05 * progress);

    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final animatedY = y + (math.sin(progress * 2 * math.pi + i) * 10);

      canvas.drawCircle(
        Offset(x, animatedY),
        2 + (random.nextDouble() * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
