import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:quick_access/routes/app_router.gr.dart';
import 'package:quickalert/quickalert.dart';
import '../services/post_services.dart';

@RoutePage()
class SignupScreen extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _systemIdController = TextEditingController();

  SignupScreen({super.key});

  Future<void> register(BuildContext context) async {
    final response = await PostService().register({
      "FIRST_NAME": _firstNameController.text,
      "LAST_NAME": _lastNameController.text,
      "USER_NAME": _emailController.text,
      "PASSWORD": _passwordController.text,
      "SYSTEM_ID": _systemIdController.text,
    });
    if (response[0]['success'] == true) {
      // ignore: use_build_context_synchronously
      AutoRouter.of(context).push(const LoginRoute());
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'Success!',
        width: 400,
        text: response[0]['msg'],
        autoCloseDuration: Duration(seconds: 3),
      );
    } else {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Something went wrong!',
        width: 400,
        text: response[0]['msg']['RESPONSE'],
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
          SingleChildScrollView(
            child: Column(
              children: [
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
                      Text('Have an account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Login'),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height - 200,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          height: 570,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                )
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create an Account',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Sign up to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 30),
                              Text(
                                'First Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              inputField('Enter your First Name', false,
                                  _firstNameController),
                              SizedBox(height: 10),
                              Text(
                                'Last Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              inputField('Enter your Last Name', false,
                                  _lastNameController),
                              SizedBox(height: 10),
                              Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              inputField(
                                  'Enter your Email', false, _emailController),
                              SizedBox(height: 10),
                              Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              inputField('Enter your Password', true,
                                  _passwordController),
                              SizedBox(height: 10),
                              Text(
                                'System Id',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              inputField(
                                  'System Id', false, _systemIdController),
                              SizedBox(height: 30),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 217, 230, 74),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize: Size(double.infinity, 50)),
                                  onPressed: () {
                                    register(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField(
      String hintText, bool obscureText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        hoverColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }
}
