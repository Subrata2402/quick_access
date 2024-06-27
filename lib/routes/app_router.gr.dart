// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;
import 'package:quick_access/screens/dashboard.dart' as _i1;
import 'package:quick_access/screens/signin.dart' as _i2;
import 'package:quick_access/screens/signup.dart' as _i3;

abstract class $AppRouter extends _i4.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    DashboardRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.DashboardScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.LoginScreen(),
      );
    },
    SignupRoute.name: (routeData) {
      final args = routeData.argsAs<SignupRouteArgs>(
          orElse: () => const SignupRouteArgs());
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.SignupScreen(key: args.key),
      );
    },
  };
}

/// generated route for
/// [_i1.DashboardScreen]
class DashboardRoute extends _i4.PageRouteInfo<void> {
  const DashboardRoute({List<_i4.PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i2.LoginScreen]
class LoginRoute extends _i4.PageRouteInfo<void> {
  const LoginRoute({List<_i4.PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i3.SignupScreen]
class SignupRoute extends _i4.PageRouteInfo<SignupRouteArgs> {
  SignupRoute({
    _i5.Key? key,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          SignupRoute.name,
          args: SignupRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignupRoute';

  static const _i4.PageInfo<SignupRouteArgs> page =
      _i4.PageInfo<SignupRouteArgs>(name);
}

class SignupRouteArgs {
  const SignupRouteArgs({this.key});

  final _i5.Key? key;

  @override
  String toString() {
    return 'SignupRouteArgs{key: $key}';
  }
}
