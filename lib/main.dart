import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/my_courses_screen.dart';
import 'screens/lesson_list_screen.dart';
import 'screens/lesson_player_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/security_screen.dart';
import 'screens/help_screen.dart';
import 'screens/about_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'models/lesson_model.dart';
import 'models/teacher_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable flag secure for all pages
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peak Mind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF25A0DC),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF142132),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF142132),
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF142132),
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF142132),
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF142132),
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF142132),
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF142132),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF142132),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF142132),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25A0DC),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF142132),
            side: const BorderSide(color: Color(0xFF142132)),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF142132),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          labelStyle: const TextStyle(color: Color(0xFF142132)),
          prefixIconColor: const Color(0xFF666666),
          suffixIconColor: const Color(0xFF666666),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF25A0DC), width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF142132),
          selectedItemColor: Color(0xFF25A0DC),
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(
            color: Color(0xFF25A0DC),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/my_courses': (context) => const MyCoursesScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/security': (context) => const SecurityScreen(),
        '/help': (context) => const HelpScreen(),
        '/about': (context) => const AboutScreen(),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        if (settings.name == '/lesson_list') {
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => LessonListScreen(
                courseId: args['courseId'] as String,
                courseTitle: args['courseTitle'] as String,
                teacher: args['teacher'] as TeacherModel,
              ),
              settings: RouteSettings(name: '/lesson_list', arguments: args),
            );
          }
        }

        return null;
      },
    );
  }
}
