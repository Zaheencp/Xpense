import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xpense/controllers/cardprovider.dart';
import 'package:xpense/controllers/firebasecontroller.dart';
import 'package:xpense/controllers/splashprovider.dart';
import 'package:xpense/screens/splash.dart';
import 'package:xpense/screens/widgets/bottomnavbar.dart';
import 'screens/bank_link_screen.dart';
import 'screens/budget_template_screen.dart';
import 'controllers/goal_provider.dart';
import 'controllers/bill_provider.dart';
import 'screens/bill_reminder_screen.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'screens/login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize(navigatorKey);

  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => SplashProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => TransactionProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => FirebaseController(),
          ),
          // SMS auto-expense feature removed
          ChangeNotifierProvider(
            create: (context) => GoalProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => BillProvider(),
          ),
        ],
        child: MaterialApp(
          title: 'Xpense',
          navigatorKey: navigatorKey,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              textTheme:
                  Theme.of(context).textTheme.apply(fontFamily: 'Roboto')),
          routes: {
            '/budget-templates': (context) => const BudgetTemplateScreen(),
            '/bill-reminders': (context) => const BillReminderScreen(),
          },
        ));
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking authentication, show the splash screen directly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Splash();
        }

        // If user is logged in, show main app
        if (snapshot.hasData && snapshot.data != null) {
          return Consumer<SplashProvider>(
            builder: (context, SplashProvider, child) {
              Widget initialScreen = const Bottom();
              return SplashProvider.isSplashDone
                  ? initialScreen
                  : const Splash();
            },
          );
        }

        // If user is not logged in, show login screen
        return Loginpage();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xpense Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BankLinkScreen()),
            );
          },
          child: const Text('Link Bank Account & View Transactions'),
        ),
      ),
    );
  }
}
