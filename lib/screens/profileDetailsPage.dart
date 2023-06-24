import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class profileDetailsPage extends StatefulWidget {
  @override
  _profileDetailsPageState createState() => _profileDetailsPageState();
}

class _profileDetailsPageState extends State<profileDetailsPage> {
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final accessToken =
        'EAAzMmo2bSDUBAPERC5WfFxAnZAdiLYxSlpRdpbxeuCCLkDWZC32nQOBdf5UWGBl3emWrZBCaUIkZCB4HTfkDyqj7OTiAH4OUaW4Ce0kWdeEhG35ihs2GYn0s8JiRu7WnqOdFrJUZBvFZB69NJvtZCiVeYRY616TeGmf0ZCFB4FK9VuRqZCY7Wq6lyq5SInZCY72eAZD';
    final response = await http.get(Uri.parse(
        'https://graph.facebook.com/v16.0/6004074063017937?fields=first_name,last_name,email,birthday,gender,profile_pic&access_token=$accessToken'));
    final data = json.decode(response.body);
    print(response.body);
    setState(() {
      _userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black, // set text color to black
          ),
        ),
        backgroundColor: Colors.white, // set background color to white
        foregroundColor: Colors.black, // set icon and button color to black
      ),
      body: _userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userData.containsKey('profile_pic'))
                    CircleAvatar(
                      backgroundImage: NetworkImage(_userData['profile_pic']),
                      radius: 50,
                    ),
                  SizedBox(height: 10),
                  Text(
                    'First Name: ${_userData.containsKey('first_name') ? _userData['first_name'] : 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Last Name: ${_userData.containsKey('last_name') ? _userData['last_name'] : 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${_userData.containsKey('email') ? _userData['email'] : 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Birthday: ${_userData.containsKey('birthday') ? _userData['birthday'] : 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gender: ${_userData.containsKey('gender') ? _userData['gender'] : 'N/A'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
