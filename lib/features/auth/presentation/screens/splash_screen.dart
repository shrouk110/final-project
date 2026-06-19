import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;



class AppColors {
  static const Color primary     = Color(0xFF0B132B);
  static const Color secondary   = Color(0xFF415A77);
  static const Color background  = Color(0xFFF1E9DB);
  static const Color background2 = Color(0xFFD7C9B8);
  static const Color buttonColor = Color(0xFFD4A38C);
  static const Color white       = Colors.white;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {


  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _decorCtrl;


  late final Animation<double>  _fadeAnim;
  late final Animation<double>  _scaleAnim;
  late final Animation<Offset>  _slideAnim;
  late final Animation<double>  _decorFade;
  late final Animation<double>  _decorScale;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.dark,
    ));


    _scaleCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve:  Curves.elasticOut,
    );

    _fadeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve:  Curves.easeIn,
    );


    _slideCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve:  Curves.easeOutCubic,
    ));

    _decorCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1000),
    );
    _decorFade = CurvedAnimation(
      parent: _decorCtrl,
      curve:  Curves.easeIn,
    );
    _decorScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _decorCtrl, curve: Curves.easeOutBack),
    );


    _decorCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeCtrl.forward();
      _scaleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideCtrl.forward();
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted) {

      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _slideCtrl.dispose();
    _decorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          Positioned(
            top:   -size.width * 0.18,
            right: -size.width * 0.12,
            child: AnimatedBuilder(
              animation: _decorCtrl,
              builder: (_, __) => Opacity(
                opacity: _decorFade.value,
                child: Transform.scale(
                  scale: _decorScale.value,
                  child: Container(
                    width:  size.width * 0.55,
                    height: size.width * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.buttonColor.withOpacity(0.55),
                    ),
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            bottom: -size.width * 0.22,
            left:   -size.width * 0.15,
            child: AnimatedBuilder(
              animation: _decorCtrl,
              builder: (_, __) => Opacity(
                opacity: _decorFade.value,
                child: Transform.scale(
                  scale: _decorScale.value,
                  child: Container(
                    width:  size.width * 0.65,
                    height: size.width * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withOpacity(0.30),
                    ),
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            top:   size.height * 0.38,
            right: size.width * 0.04,
            child: AnimatedBuilder(
              animation: _decorCtrl,
              builder: (_, __) => Opacity(
                opacity: _decorFade.value * 0.6,
                child: Container(
                  width:  14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.45),
                  ),
                ),
              ),
            ),
          ),


          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [


                  ScaleTransition(
                    scale: _scaleAnim,
                    child: const _VisionCareLogo(),
                  ),

                  const SizedBox(height: 28),

                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Row(
                        mainAxisSize:    MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dividerLine(),
                          const SizedBox(width: 10),
                          Text(
                            'OPHTHALMIC CARE',
                            style: TextStyle(
                              fontSize:      12,
                              fontWeight:    FontWeight.w600,
                              color:         AppColors.primary.withOpacity(0.75),
                              letterSpacing: 3.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _dividerLine(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //
          Positioned(
            bottom: 36,
            left:   0,
            right:  0,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Container(
                      width:  80,
                      height: 1,
                      color:  AppColors.buttonColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OPHTHALMIC VIEW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:      10,
                        fontWeight:    FontWeight.w500,
                        color:         AppColors.primary.withOpacity(0.55),
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
    width:  32,
    height: 1,
    color:  AppColors.primary.withOpacity(0.35),
  );
}


class _VisionCareLogo extends StatelessWidget {
  const _VisionCareLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width:  160,
          height: 160,
          decoration: BoxDecoration(
            shape:  BoxShape.circle,
            color:  AppColors.white,
            border: Border.all(
              color: AppColors.background2,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:       Colors.black.withOpacity(0.08),
                blurRadius:  20,
                spreadRadius: 2,
                offset:      const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [


              CustomPaint(
                size:    const Size(160, 160),
                painter: _ArcPainter(),
              ),


              Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  _EyeIcon(),

                  const SizedBox(height: 4),

                  const Text(
                    'VISION CARE',
                    style: TextStyle(
                      fontSize:      13,
                      fontWeight:    FontWeight.w800,
                      color:         AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),

                  Text(
                    'Clear Sight',
                    style: TextStyle(
                      fontSize:   8,
                      fontStyle:  FontStyle.italic,
                      color:      AppColors.secondary.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _EyeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  64,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size:    const Size(64, 38),
            painter: _EyeShapePainter(),
          ),
          Container(
            width:  22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
            ),
            child: Center(
              child: Container(
                width:  10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          Positioned(
            top:   6,
            right: 18,
            child: Container(
              width:  5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _EyeShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color     = AppColors.primary
      ..style     = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2, -size.height * 0.4,
      size.width,     size.height / 2,
    );
    path.quadraticBezierTo(
      size.width / 2, size.height * 1.4,
      0,              size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = AppColors.buttonColor.withOpacity(0.25)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;


    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      paint,
    );


    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}