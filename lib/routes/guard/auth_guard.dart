import 'package:auto_route/auto_route.dart';
import 'package:quick_access/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('IS_LOGGED_IN') ?? false;
    if (isLoggedIn) {
      resolver.next(true);
    } else {
      router.push(const LoginRoute());
    }
  }
}