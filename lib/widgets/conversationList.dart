import 'package:flutter/material.dart';
import '../screens/chatDetailPage.dart';
import 'package:http/http.dart' as http;

class ConversationList extends StatefulWidget {
  final String fromName;
  final String assignation;
  final String conversationId;
  final String lastMessageCreatedTime;
  final String username;
  final bool isAssignedChatsPage;

  const ConversationList({
    Key? key,
    required this.fromName,
    required this.assignation,
    required this.conversationId,
    required this.lastMessageCreatedTime,
    required this.username,
    required this.isAssignedChatsPage,
  }) : super(key: key);

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              conversationId: widget.conversationId,
              fromName: widget.fromName,
              lastMessageCreatedTime: widget.lastMessageCreatedTime,
              username: widget.username,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Icon(Icons.person),
              radius: 30,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.fromName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.assignation,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    widget.lastMessageCreatedTime,
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.assignation.contains('Free to assign'),
              child: SizedBox(
                width: 150.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () async {
                        final response = await http.post(Uri.parse('http://192.168.122.1:3000/assign_chat'), body: {
                          'conversationId': widget.conversationId,
                          'username': widget.username,
                        });

                        if (response.statusCode == 200) {
                          // Assigned chat updated successfully
                        } else {
                          // Error updating assigned chats
                        }
                      },
                      child: Text(
                        'Assign',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !widget.assignation.contains('Free to assign') && widget.isAssignedChatsPage,
              child: SizedBox(
                width: 150.0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () async {
                        final response = await http.post(Uri.parse('http://192.168.122.1:3000/complete_chat'), body: {
                          'conversationId': widget.conversationId,
                          'username': widget.username,
                        });

                        if (response.statusCode == 200) {
                          // Completed chat updated successfully
                        } else {
                          // Error updating completed chats
                        }
                      },
                      child: Text(
                        'Complete',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}