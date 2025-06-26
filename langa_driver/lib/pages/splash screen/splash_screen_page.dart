import 'dart:async';
import 'package:flutter/services.dart';
import 'package:langas_driver/flutter_flow/flutter_flow_animation.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:langas_driver/nav/nav.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'rowOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 630.ms,
          duration: 600.ms,
          begin: const Offset(-400.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    // Navigate to the login page after a delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/loginPage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/logo2.png',
                  width: 140.0,
                  height: 120.0,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140.0,
                      height: 120.0,
                      color: Colors.white,
                      child: const Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ],
          ).animateOnPageLoad(animationsMap['rowOnPageLoadAnimation']!),
        ),
      ),
    );
  }
}
