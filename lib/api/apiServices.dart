import 'dart:convert';
import 'package:http/http.dart' as http;

List<dynamic> dataList = [];
List<String> fromNames = [];
List<String> conversationIds = [];
List<Map<String, dynamic>> messages = [];

Future<void> getFromData() async {
  var url = Uri.parse('http://192.168.122.1:3000/messages');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    dataList = jsonDecode(response.body);

    // Sort the dataList in descending order based on the created_time field
    dataList.sort((a, b) => b['created_time'].compareTo(a['created_time']));

    for (var data in dataList) {
      if (data['from_name'] != 'Arafath Fruits Center') {
        // Check if this from_name has already been encountered
        if (!fromNames.contains(data['from_name'])) {
          // Add this from_name to the list of unique from names
          fromNames.add(data['from_name']);
          conversationIds.add(data['conversation_id']);
        }
      }
    }
  } else {
    print('Error retrieving data from server.');
  }
}

Future<void> fetchMessages() async {
  final response = await http.get(Uri.parse('http://192.168.122.1:3000/messages'));
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData != null) {
      messages = List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>());
    }
  }
}


Future<String?> fetchLatestMessage(String conversationId) async {
  try {
    final response = await http.get(Uri.parse('http://192.168.122.1:3000/messages'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final latestMessage = List<Map<String, dynamic>>.from(responseData.cast<Map<String, dynamic>>())
          .where((message) => message['conversation_id'] == conversationId && message['from_name'] != 'Arafath Fruits Center')
          .reduce((latest, message) => DateTime.parse(latest['created_time']).isAfter(DateTime.parse(message['created_time'])) ? latest : message);
      final messageText = latestMessage['message'];
      return messageText;
    } else {
      print('HTTP GET request returned status code ${response.statusCode}');
    }
  } catch (error) {
    print('An error occurred: $error');
  }
  return null;
}

Future<String> getAllChatDetails(String conversationId) async {
  final response = await http.get(
    Uri.parse('http://192.168.122.1:3000/assignedchatdetails'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    for (var item in data) {
      if (item['conversation_id'] == conversationId) {
        return item['staff_name'];
      }
    }
  }
  return '';
}

Future<String> getAssignedChatDetails(String conversationId) async {
  final response = await http.get(
    Uri.parse('http://192.168.122.1:3000/assignedchatdetails'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    for (var item in data) {
      if (item['conversation_id'] == conversationId &&
          !item['status'].toLowerCase().contains('completed')) {
        return item['staff_name'];
      }
    }
  }
  return '';
}

Future<String> getCompletedChatDetails(String conversationId) async {
  final response = await http.get(
    Uri.parse('http://192.168.122.1:3000/assignedchatdetails'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    for (var item in data) {
      if (item['conversation_id'] == conversationId && item['status'] == 'completed') {
        return item['staff_name'];
      }
    }
  }
  return '';
}

Future<void> sendMessage(String messageText) async {
  String fromID = "6004074063017937";
  String accessToken = "EAAzMmo2bSDUBAPERC5WfFxAnZAdiLYxSlpRdpbxeuCCLkDWZC32nQOBdf5UWGBl3emWrZBCaUIkZCB4HTfkDyqj7OTiAH4OUaW4Ce0kWdeEhG35ihs2GYn0s8JiRu7WnqOdFrJUZBvFZB69NJvtZCiVeYRY616TeGmf0ZCFB4FK9VuRqZCY7Wq6lyq5SInZCY72eAZD";

  Map<String, dynamic> requestBody = {
    "recipient": {"id": fromID},
    "messaging_type": "RESPONSE",
    "message": {"text": messageText}
  };

  var response = await http.post(
    Uri.parse('https://graph.facebook.com/v13.0/me/messages?access_token=$accessToken'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send message: ${response.statusCode}');
  }
}

