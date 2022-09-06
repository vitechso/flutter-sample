// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MyStyle.dart';
import 'package:dmb_app/Dashboard.dart';
import 'package:http/http.dart' as http;

class MyLoginWidget extends StatefulWidget {
  const MyLoginWidget({Key? key}) : super(key: key);

  @override
  State<MyLoginWidget> createState() => _MyLoginWidgetState();
}

class _MyLoginWidgetState extends State<MyLoginWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  loginFun(companyCode, screenCode) async {
    Map data = {'company_code': companyCode, 'screen_code': screenCode};
    print(data.toString());
    final response = await http.post(
      Uri.parse('http://143.110.181.88/api/check-companyscreen'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: data,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('screen_code', screenCode);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              height: 300,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(
                    "Welcome D.M.B",
                    style: titleText,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80))),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 30),
                transform: Matrix4.translationValues(0.0, -60.0, 0.0),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Company Code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user name';
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Screen Code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter correct password';
                  }
                  return null;
                },
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    shadowColor: Colors.blueAccent,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(35.0)), //////// HERE
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      // Map data = {
                      //   'company_code': nameController.text,
                      //   'screen_code': passwordController.text
                      // };
                      // print(data.toString());
                      // final response = await http.post(
                      //   Uri.parse(
                      //       'http://143.110.181.88/api/check-companyscreen'),
                      //   headers: {
                      //     "Accept": "application/json",
                      //     "Content-Type": "application/x-www-form-urlencoded"
                      //   },
                      //   body: data,
                      // );
                      // print(response.statusCode);
                      // if (response.statusCode == 200) {
                      //   // ignore: use_build_context_synchronously
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const Dashboard()),
                      //   );
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text('Login successfully')),
                      //   );
                      // } else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text('Invalid credentials')),
                      //   );
                      // }
                      loginFun(nameController.text, passwordController.text);
                    }
                  },
                )),
          ],
        ));
  }
}
