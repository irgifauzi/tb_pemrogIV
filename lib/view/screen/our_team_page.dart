import 'package:flutter/material.dart';

class OurTeamPage extends StatelessWidget {
  const OurTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Warna latar
      appBar: AppBar(
        title: const Text(
          'Our Team',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Team Developer Ramen Store",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  TeamMemberCard(
                    imagePath: 'assets/jul.jpg',
                    name: 'Dzulkifli Faiz Nurmufid',
                    npm: '714220030',
                  ),
                  SizedBox(height: 20),
                  TeamMemberCard(
                    imagePath: 'assets/irgi.jpg',
                    name: 'Irgi Achmad Fauzi',
                    npm: '714220035',
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

class TeamMemberCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String npm;

  const TeamMemberCard({
    required this.imagePath,
    required this.name,
    required this.npm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(imagePath),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NPM: $npm',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 12),
            Icon(Icons.star, color: Colors.amber.shade700, size: 28),
          ],
        ),
      ),
    );
  }
}
