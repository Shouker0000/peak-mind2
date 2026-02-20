import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Peak Mind'),
        backgroundColor: const Color(0xFF142132),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Image(image: AssetImage('assets/logos/logo_empty.png')),
            const SizedBox(height: 20),
            const Text(
              'Peak Mind',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Peak Mind is your personal gateway to mental wellness and personal development. '
                    'We provide expert-led courses and resources to help you master your mind and transform your life.',
                    style: TextStyle(height: 1.6),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Expert-curated courses\n'
                    '• Interactive learning experience\n'
                    '• Track your progress\n'
                    '• Access to certified instructors\n'
                    '• Community support',
                    style: TextStyle(height: 1.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
