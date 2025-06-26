import 'package:flutter/material.dart';
import 'package:langas_driver/nav/nav.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // App logo or icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/logo2.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.drive_eta_rounded,
                        size: 60,
                        color: Color(0xFF2451DC),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/driver_service.png',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            size: 60,
                            color: Color(0xFF2451DC),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "24/7",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2451DC),
                            ),
                          ),
                          Text(
                            "SERVICE",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                "Langas Driver",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                "Drive with us - Services You Can Trust!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                "Welcome to Langas Driver! Access trusted driving opportunities for flexible earnings with a hassle-free experience.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed('LoginPage'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A1C40),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => context.pushNamed('RegistrationPage'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A1C40),
                        side: const BorderSide(
                          color: Color(0xFF0A1C40),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom spacer and progress indicator
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1C40),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
