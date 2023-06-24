import 'dart:async';
import 'package:chatter/screens/profileDetailsPage.dart';
import 'package:flutter/material.dart';
import '../api/apiServices.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final String fromName;
  final String lastMessageCreatedTime;
  final String username;

  ChatDetailPage({required this.conversationId, required this.fromName, required this.lastMessageCreatedTime, required this.username});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {

  final TextEditingController _textController = TextEditingController();
  Timer? _timer;
  String? latestMessage;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchMessages().then((messages) {
        setState(() {
          // Rebuild the widget with the new messages
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
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => profileDetailsPage(),
                            ),
                          );
                        },
                        child: Text(
                          widget.fromName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Assigned to: ' + widget.username,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              reverse: true,
              children: (messages
                  .where((message) =>
              message['conversation_id'] == '${widget.conversationId}')
                  .toList()..sort((a, b) => DateTime.parse(b['created_time']).compareTo(DateTime.parse(a['created_time']))))
                  .map<Widget>((message) {
                final from = message['from_name'];
                final text = message['message'] ?? '';
                final timestamp = DateTime.parse(message['created_time']);
                final formattedTime =
                    '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2),
                  child: Align(
                    alignment: from == 'Arafath Fruits Center'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: from == 'Arafath Fruits Center'
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            from,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: from == 'Arafath Fruits Center'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            text,
                            style: TextStyle(
                              color: from == 'Arafath Fruits Center'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: from == 'Arafath Fruits Center'
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          final messageText = _textController.text;
                          await sendMessage(messageText);
                          _textController.clear();
                        },
                      ),
                    ),
                    // Add the following listener to detect when the user presses the "Enter" key
                    onSubmitted: (messageText) async {
                      await sendMessage(messageText);
                      _textController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
