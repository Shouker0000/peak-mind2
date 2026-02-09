import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'courses_screen.dart';
import 'my_courses_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      _buildHomeContent(),
      const CoursesScreen(),
      const MyCoursesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF142132),
        selectedItemColor: const Color(0xFF25A0DC),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with greeting
          Container(
            color: const Color(0xFF142132),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<User?>(
                          future: Future.value(_auth.currentUser),
                          builder: (context, snapshot) {
                            String userName = 'User';
                            if (snapshot.hasData && snapshot.data != null) {
                              userName = snapshot.data!.displayName ??
                                  snapshot.data!.email?.split('@')[0] ??
                                  'User';
                            }
                            return Text(
                              'Good Morning, $userName',
                              style: const TextStyle(
                                color: Color(0xFF25A0DC),
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF25A0DC),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF142132),
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Featured banner carousel
          SizedBox(
            height: 200,
            child: PageView(
              children: [
                _buildBannerCard(
                  'Youssef Ali',
                  'Introduction to Education with 0-4 IQ Series of Experience',
                  'https://via.placeholder.com/400x200?text=Teacher+1',
                ),
                _buildBannerCard(
                  'Emily Johnson',
                  'Music and Art for Kids aged 6-12 years old',
                  'https://via.placeholder.com/400x200?text=Teacher+2',
                ),
                _buildBannerCard(
                  'Benjamin Rodriguez',
                  'Programming for children aged 10-15',
                  'https://via.placeholder.com/400x200?text=Teacher+3',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Top Courses section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Teachers',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildTeacherCard(
                        'Emily Johnson',
                        'Music and Art for Kids\naged 6-12 years old',
                        '600 EGP/M',
                        'https://via.placeholder.com/150x150?text=Emily',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTeacherCard(
                        'Benjamin Rodriguez',
                        'Programming for\nchildren aged 10-15',
                        '600 EGP/M',
                        'https://via.placeholder.com/150x150?text=Benjamin',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Call to action card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFB3D9FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Color(0xFF142132),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's Start With",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Text(
                              'Badaya Academy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () {},
                        child: const Text('Become An Instructor'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("I'm A Student"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBannerCard(String name, String description, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(
    String name,
    String description,
    String price,
    String imageUrl,
  ) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '600 EGP/M',
                  style: TextStyle(
                    color: Color(0xFF25A0DC),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Details',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Subscribe',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
