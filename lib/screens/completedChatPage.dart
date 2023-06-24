import 'dart:async';
import 'package:flutter/material.dart';
import '../api/apiServices.dart';
import '../widgets/conversationList.dart';
import 'package:intl/intl.dart';
import 'loginPage.dart';
import 'package:http/http.dart' as http;

class completedChatPage extends StatefulWidget {
  final String username;

  const completedChatPage({Key? key, required this.username}) : super(key: key);

  @override
  _completedChatPageState createState() => _completedChatPageState();
}

class _completedChatPageState extends State<completedChatPage> {

  bool _isAssignedChatsPage = false;
  Timer? _timer;
  String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      getFromData().then((messages) {
        setState(() {
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        primary: false,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Conversations",
                      style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // Perform logout action
                        await http.post(
                            Uri.parse('http://192.168.122.1:3000/logout'),
                            body: {'username': widget.username});
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.pink[50],
                        ),
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.logout,
                              color: Colors.pink,
                              size: 20,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (fromNames.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ListView.builder(
                itemCount: fromNames.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final String fromName = fromNames[index];
                  final String conversationId = conversationIds[index];

                  // find the last message created time for this conversation id
                  String lastMessageCreatedTime = '';
                  for (var data in dataList.reversed) {
                    if (data['conversation_id'] == conversationId) {
                      lastMessageCreatedTime = data['created_time'];
                      break;
                    }
                  }

                  final formattedDateTime = formatDateTime(lastMessageCreatedTime);

                  // call getAssignedChatDetails to get staff_name for this conversationId
                  Future<String> completedFuture = getCompletedChatDetails(conversationId);

                  return FutureBuilder<String>(
                      future: completedFuture,
                      builder: (context, snapshot) {
                        String assignation = snapshot.data ?? '';
                        // Only show the conversation if it's assigned to the logged-in user
                        if (assignation == widget.username) {
                          return ConversationList(
                            username: widget.username,
                            conversationId: conversationId,
                            fromName: fromName,
                            assignation: 'Assigned to: ' + assignation,
                            lastMessageCreatedTime: formattedDateTime,
                            isAssignedChatsPage: _isAssignedChatsPage,
                          );
                        } else {
                          // Return an empty container if the conversation is not assigned to the logged-in user
                          return Container();
                        }
                      }
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
