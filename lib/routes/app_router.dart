import 'package:auto_route/auto_route.dart';
import 'package:quick_access/routes/guard/auth_guard.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {

  @override
  List<AutoRoute> get routes => [
    // Initial route is the first page that will be displayed
    AutoRoute(page: DashboardRoute.page, initial: true, guards: [AuthGuard()]),

    // Other routes
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: SignupRoute.page),
  ];
}