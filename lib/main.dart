import 'package:dmb_app/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:dmb_app/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = prefs.getString('screen_code');
  print(isLoggedIn);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: isLoggedIn != null ? Dashboard() : MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255)),
      // home: const Scaffold(
      //   body: MyLoginWidget(),
      // ),
      home: const SafeArea(
        // top: true
        child: Scaffold(body: MyLoginWidget()),
      ),
    );
  }
}
