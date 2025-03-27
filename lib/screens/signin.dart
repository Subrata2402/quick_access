
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

  LoginScreen({super.key});

  Future<void> login(BuildContext context) async {
    final response = await PostService().login({
      "USER_NAME": _emailController.text,
      "PASSWORD": _passwordController.text,
    });
    // print(response[0]);
    if (response[0]['status'] == 'SUCCESS') {
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('IS_LOGGED_IN', true);
      await prefs.setString(
          'USER_NAME', response[0]['user_details'][0]['USER_NAME']);
      await prefs.setString(
          'FIRST_NAME', response[0]['user_details'][0]['FIRST_NAME']);
      await prefs.setString(
          'LAST_NAME', response[0]['user_details'][0]['LAST_NAME']);
      await prefs.setString(
          'PASSWORD', response[0]['user_details'][0]['PASSWORD']);
      await prefs.setString(
          'ID', response[0]['user_details'][0]['ID'].toString());
      await prefs.setString(
          'UNIQUE_ID', response[0]['user_details'][0]['UNIQUE_ID'].toString());

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
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/aivista_logo.png',
                  width: 50,
                  height: 50,
                ),
                const Spacer(),
                const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 167, 191, 68),
                ),
                const Text('New User?'),
                TextButton(
                  onPressed: () {
                    AutoRouter.of(context).push(SignupRoute());
                  },
                  child: const Text('Sign Up'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  height: 500,
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500),
                      ),
                      const Text('Sign in to continue'),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIconColor: const Color.fromARGB(255, 167, 191, 68),
                          hintText: 'user@gmail.com',
                          prefixIcon: const Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 167, 191, 68)),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 167, 191, 68))),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          prefixIconColor: const Color.fromARGB(255, 167, 191, 68),
                          hintText: 'Enter Password',
                          prefixIcon: const Icon(Icons.lock),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 167, 191, 68)),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 167, 191, 68))),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 134, 157, 64),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                login(context);
                                // Navigator.pushNamed(context, '/dashboard');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password?'),
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
