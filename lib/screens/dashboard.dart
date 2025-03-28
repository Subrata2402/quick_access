import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:quick_access/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/post_services.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  Map overlayEntries = {};
  String? buttonName;
  // bool isAPModalOpen = false;

  // Store the address book data
  List<dynamic> addressBook = [];

  // Check the internet connection status
  bool connectionStatus = false;
  final Connectivity _connectivity = Connectivity();

  // Socket connection
  // http://122.163.121.176:3008
  final IO.Socket _socket = IO.io('http://122.163.121.176:3008', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  _sendRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_idController.text.trim().isEmpty) {
      return QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Error!',
        width: 400,
        text: 'Please enter the email or ID',
      );
    }
    final sendData = {
      'roomId': _idController.text,
      'socket_id': prefs.getString('socket_id'),
      'user': {
        "UserName": prefs.getString('USER_NAME'),
        "Name":
            "${prefs.getString('FIRST_NAME')} ${prefs.getString('LAST_NAME')}",
        "UniqueId": prefs.getString('UNIQUE_ID'),
      },
    };
    _socket.emitWithAck('join-message', jsonEncode(sendData), ack: (data) {
      print('Join message $data');
    });
  }

  _updateSocketUser(socketId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await PostService().updateSocketUser({
      "unique_id": prefs.getString('UNIQUE_ID'),
      "socket_id": socketId,
    });
    await prefs.setString('socket_id', socketId);
  }

  _connectSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _socket.connect();
    _socket.onConnect((_) {
      print('connect: ${_socket.id}');
      // _socket.emitWithAck('get_socket', 'i send', ack: (data) {
      //   print('Received socket ID from server: $data');
      // });
    });

    _socket.on('user-offline', (data) {
      // print(data);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'User Offline!',
        width: 400,
        text: 'User is offline',
        autoCloseDuration: const Duration(seconds: 3),
      );
    });

    _socket.on('access-request', (data) {
      print('Access request: ${data[0]}');
      var connectUserData = jsonDecode(data[0]);
      connectUserData['screendata'] = {
        'width': 1200,
        'height': 800,
        'userMac': '',
        'user_id': prefs.getString('ID'),
        'username': prefs.getString('USER_NAME'),
      };
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'Access Request!',
        width: 400,
        text: 'User wants to access your system',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () {
          _socket.emit('accept', jsonEncode(connectUserData));
          Navigator.of(context).pop();
        },
        onCancelBtnTap: () {
          _socket.emit('reject', data[0]);
          Navigator.of(context).pop();
        },
      );
    });

    _socket.on('join-you', (data) {
      print("Join you: $data");
    });

    _socket.on('you-reject', (data) {
      print('You reject: $data');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Request Rejected!',
        width: 400,
        text: 'Request rejected by user',
      );
    });

    
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    fetchAddressBook();
    _connectSocket();
    Future.delayed(const Duration(seconds: 1), () {
      _updateSocketUser(_socket.id);
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  Future fetchAddressBook() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await PostService().getAddressBook({
      "user_id": prefs.getString('ID'),
    });
    addressBook =
        response.where((element) => element['Isdelete'] == 0).toList();
  }

  Future checkConnection() async {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final result = results.last;
      if (result == ConnectivityResult.none) {
        setState(() {
          // print('No internet connection');
          connectionStatus = false;
        });
      } else {
        setState(() {
          // print('Internet connection available');
          connectionStatus = true;
        });
      }
    });

    final result = await _connectivity.checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (result == ConnectivityResult.none) {
      setState(() {
        // print('No internet connection');
        connectionStatus = false;
      });
    } else {
      setState(() {
        // print('Internet connection available');
        connectionStatus = true;
      });
    }
  }

  Future deleteAddressBook(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await PostService().deleteAddressBook({
      "email_id": email,
      "user_id": prefs.getString('ID'),
    });
    print(response);
    if (response['response'] == 'deleted') {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      fetchAddressBook();
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'Success!',
        width: 400,
        text: 'Address deleted successfully',
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Something went wrong!',
        width: 400,
        text: response['return'],
      );
    }
  }

  Future insertAddressBook() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await PostService().insertAddressBook({
      "email": _emailController.text,
      "userid": prefs.getString('ID'),
    });
    // print(response);
    if (response['return'] == 'Added') {
      fetchAddressBook();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.success,
        title: 'Success!',
        width: 400,
        text: 'Address added successfully',
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Something went wrong!',
        width: 400,
        text: response['return'],
      );
    }
  }

  void showOverlay(BuildContext context, String buttonName) {
    if (!overlayEntries.containsKey(buttonName) && overlayEntries.length > 0) {
      // Overlay is currently shown, so remove it
      overlayEntries[this.buttonName]!.remove();
      overlayEntries.remove(this.buttonName);
    }
    if (overlayEntries.containsKey(buttonName)) {
      // Overlay is currently shown, so remove it
      overlayEntries[buttonName]!.remove();
      overlayEntries.remove(buttonName);
    } else {
      // Overlay is not shown, so insert it
      OverlayState overlayState = Overlay.of(context);
      overlayEntries[buttonName] = OverlayEntry(
        builder: (context) => buttonName == 'menu'
            ? _menuContainer(context)
            : _profileContainer(context),
      );

      overlayState.insert(overlayEntries[buttonName]!);
      this.buttonName = buttonName;
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await PostService().logout({
      "USER_NAME": prefs.getString('USER_NAME'),
      "PASSWORD": prefs.getString('PASSWORD'),
    });
    // print(response);
    if (response['RESPONSE'] == 'SUCCESS') {
      await prefs.clear();
      // ignore: use_build_context_synchronously
      AutoRouter.of(context).push(const LoginRoute());
      // ignore: use_build_context_synchronously
      showOverlay(context, 'profile');
    } else {
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Something went wrong!',
        width: 400,
        text: response['RESPONSE'],
      );
    }
  }

  Widget _profileContainer(BuildContext context) {
    return Positioned(
      top: 50.0,
      right: 130.0,
      child: Material(
        elevation: 4.0,
        child: Container(
          height: 100,
          width: 160,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Manage Account',
                    style: TextStyle(color: Colors.black),
                  )),
              TextButton(
                onPressed: () {
                  logout(context);
                },
                child: const Text('Logout', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuContainer(BuildContext context) {
    return Positioned(
      top: 50.0,
      right: 10.0,
      child: Material(
        elevation: 4.0,
        child: Container(
          height: 450,
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Address Book',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('In Contacts',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 5),
              Container(
                height: 150,
                color: const Color.fromARGB(255, 249, 223, 253),
                child: ListView.separated(
                  itemCount: addressBook.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 5,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addressBook[index]['email_id'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text("Id: ${addressBook[index]['cl_UNIQUE_ID']}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Active People',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 5),
              Container(
                height: 80,
                color: const Color.fromARGB(255, 249, 223, 253),
                child: ListView.separated(
                  itemCount: addressBook.length,
                  separatorBuilder: (context, index) {
                    if (addressBook[index]['cl_islogin'] == 1) {
                      return const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        height: 5,
                      );
                    } else {
                      return Container();
                    }
                  },
                  itemBuilder: (context, index) {
                    if (addressBook[index]['cl_islogin'] == 1) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              addressBook[index]['email_id'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 10,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                    "Id: ${addressBook[index]['cl_UNIQUE_ID']}"),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    _idController.text = addressBook[index]
                                            ['cl_UNIQUE_ID']
                                        .toString();
                                  },
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    size: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      text:
                                          'You want to delete this user from your address book?',
                                      confirmBtnColor: Colors.green,
                                      width: 400,
                                      onConfirmBtnTap: () {
                                        deleteAddressBook(
                                            addressBook[index]['email_id']);
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    size: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    maximumSize: const Size(180, 50),
                    minimumSize: const Size(180, 50)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SizedBox(
                          width: 350,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Center(
                                  child: Text('Add People',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Email:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 171, 212, 77),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 171, 212, 77),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    onPressed: () {
                                      insertAddressBook();
                                    },
                                    child: const Text('Save',
                                        style: TextStyle(color: Colors.white))),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      minimumSize: const Size(double.infinity, 50),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close',
                                        style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    Text(
                      'Add People',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background images should be added first
          Image.asset(
            'assets/images/Vector_Graphics.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            top: 100,
            left: 60,
            child: Image.asset(
              'assets/images/Vector_Woman.png',
              fit: BoxFit.cover,
              width: 600,
            ),
          ),
          Positioned(
            top: 450,
            left: 150,
            child: Image.asset(
              'assets/images/Vector_Man.png',
              // fit: BoxFit.cover,
              width: 400,
              height: 300,
            ),
          ),
          // Interactive widgets should be added last
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(color: Colors.orange[400], boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 52, 48, 48).withOpacity(0.5),
                spreadRadius: 6,
                blurRadius: 5,
                // offset: Offset(0, 1),
              )
            ]),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/aivista_logo.png',
                  scale: 4,
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'File',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Window',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Help',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings)),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      showOverlay(context, 'profile');
                    },
                    tooltip: 'Profile',
                    icon: const Icon(Icons.person)),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      // setState(() {});
                    },
                    tooltip: connectionStatus ? 'Connected' : 'Disconnected',
                    icon: Icon(
                      Icons.circle,
                      color: connectionStatus ? Colors.green : Colors.red,
                    )),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      showOverlay(context, 'menu');
                    },
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu_outlined))
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 150,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 350,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 52, 48, 48).withOpacity(0.5),
                    // spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Provide Support',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: 'Email Contact E-mail or ID',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 171, 212, 77),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 171, 212, 77),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // checkbox
                  Checkbox(value: true, onChanged: (bool? value) {}),
                  const Text(
                    'Save remote address',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 213, 249, 102),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _sendRequest();
                      },
                      child: const Text(
                        'Connect',
                        style: TextStyle(color: Colors.black),
                      )),
                  const SizedBox(height: 10),
                  const Text('You can share your ID & Password'),
                  // SizedBox(height: 10),
                  const Text('Your ID: 123 456 789'),
                  // SizedBox(height: 10),
                  const Text('Your Password: 35@rm8#12'),
                  // SizedBox(height: 10),
                  const Icon(Icons.book_rounded)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
