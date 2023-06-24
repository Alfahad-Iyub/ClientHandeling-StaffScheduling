import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 3,
                  child: Image.asset('lib/images/AppIcon.png'),
                ),
                const Text('Username', style: TextStyle(color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,),),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.email, color: Colors.white,),
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Password', style: TextStyle(color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,),),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.lock, color: Colors.white,),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                GestureDetector(
                  onTap: () async {
                    final response = await http.post(
                      Uri.parse('http://192.168.122.1:3000/login'),
                      body: {
                        'username': _usernameController.text,
                        'password': _passwordController.text,
                      },
                    );

                    if (response.statusCode == 200) {
                      // Login successful
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(username: _usernameController.text)),
                      );

                    } else {
                      // Login failed
                      final message = jsonDecode(response.body)['message'];
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Login failed'),
                          content: Text(message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black,
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}