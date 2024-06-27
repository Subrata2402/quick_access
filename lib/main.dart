import 'package:flutter/material.dart';
import 'package:quick_access/routes/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppRouter appRouter = AppRouter();
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Dashboard',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   initialRoute: '/',
    //   routes: {
    //     '/': (context) => DashboardScreen(),
    //     '/signin': (context) => LoginScreen(),
    //     '/signup': (context) => SignupScreen(),
    //   },
    // );
    return MaterialApp.router(
      routerConfig: appRouter.config(),
    );
  }
}