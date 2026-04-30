import 'package:flutter/material.dart';
import 'package:musk_mover/app_theme.dart';

void main() {
  runApp(const MuskMoverApp());
}

class MuskMoverApp extends StatelessWidget {
  const MuskMoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuskMover',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MUSKMOVER'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LOGISTICS & MOVING',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Relocate with ease,\nanywhere in Nigeria.',
                    style: textTheme.displayLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Professional moving services for your home and office. Fast, secure, and reliable.',
                    style: textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('GET A QUOTE'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Our Services', style: textTheme.displayMedium),
                  const SizedBox(height: 32),
                  _buildServiceCard(
                    context,
                    icon: Icons.home_rounded,
                    title: 'Home Moving',
                    description: 'Full-service residential relocation handled by experts.',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    icon: Icons.business_rounded,
                    title: 'Office Relocation',
                    description: 'Minimize downtime with our efficient office moving solutions.',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    icon: Icons.local_shipping_rounded,
                    title: 'Interstate Haulage',
                    description: 'Safe transport of goods across all states in Nigeria.',
                  ),
                ],
              ),
            ),
            
            // Footer-like CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              color: Colors.white,
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text('Need Help?', style: textTheme.displayMedium),
                  const SizedBox(height: 8),
                  const Text('Speak with our support team today.'),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('CONTACT US', style: TextStyle(color: AppTheme.primaryColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
