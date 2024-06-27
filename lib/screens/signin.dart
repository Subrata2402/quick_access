// import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:quick_access/routes/app_router.gr.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/post_services.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await PostService().login({
      "USER_NAME": _emailController.text,
      "PASSWORD": _passwordController.text,
    });
    // print(response[0]);
    if (response[0]['status'] == 'SUCCESS') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('IS_LOGGED_IN', true);
      await prefs.setString('USER_NAME', response[0]['user_details'][0]['USER_NAME']);
      await prefs.setString('PASSWORD', response[0]['user_details'][0]['PASSWORD']);
      await prefs.setString('ID', response[0]['user_details'][0]['ID'].toString());

      // ignore: use_build_context_synchronously
      AutoRouter.of(context).push(const DashboardRoute());
    } else {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Something went wrong!',
        width: 400,
        text: response[0]['status'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Vector_Graphics.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/aivista_logo.png',
                  width: 50,
                  height: 50,
                ),
                Spacer(),
                Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 167, 191, 68),
                ),
                Text('New User?'),
                TextButton(
                  onPressed: () {
                    AutoRouter.of(context).push(SignupRoute());
                  },
                  child: Text('Sign Up'),
                )
              ],
            ),
          ),
          SizedBox(
            height: double.infinity,
            // width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/RAT_Image01.png',
                  // fit: BoxFit.cover,
                  width: 600,
                  height: 500,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  height: 500,
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500),
                      ),
                      Text('Sign in to continue'),
                      SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIconColor: Color.fromARGB(255, 167, 191, 68),
                          hintText: 'user@gmail.com',
                          prefixIcon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 167, 191, 68)),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 167, 191, 68))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          prefixIconColor: Color.fromARGB(255, 167, 191, 68),
                          hintText: 'Enter Password',
                          prefixIcon: Icon(Icons.lock),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 167, 191, 68)),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 167, 191, 68))),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 134, 157, 64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                login(context);
                                // Navigator.pushNamed(context, '/dashboard');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: () {},
                            child: Text('Forgot Password?'),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
