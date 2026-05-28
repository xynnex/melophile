import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/responsive.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: res.wp(30),
                      height: res.wp(30),
                      padding: EdgeInsets.all(res.wp(5)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppTheme.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(res.wp(8)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gradientColors.first.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/app_logo.svg',
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: res.hp(4)),
                    Text(
                      'MELOPHILE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: res.sp(28),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                    SizedBox(height: res.hp(1)),
                    Text(
                      'Music for the Soul',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: res.sp(14),
                        letterSpacing: 2,
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
