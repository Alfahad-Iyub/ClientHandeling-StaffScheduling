import 'package:chatter/screens/loginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chatter());
}

class Chatter extends StatelessWidget {
  const Chatter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatter',
      theme: ThemeData(
          fontFamily: 'Poppins',
          primaryColor: Colors.white,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 22.0, color: Colors.redAccent),
            headline2: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent),
            bodyText1: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.blueAccent),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.redAccent)),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
