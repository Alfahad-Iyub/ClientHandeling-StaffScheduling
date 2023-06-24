const axios = require('axios');
const mysql = require('mysql2/promise');
const { SessionsClient } = require('@google-cloud/dialogflow');

class DialogFlowBot {
  async run() {
    const dialogFlowClient = new SessionsClient({
      keyFilename: './assets/dialog_flow_auth.json',
    });

    const connection = await mysql.createConnection({
      host: 'localhost',
      port: 3307,
      user: 'root',
      password: '',
      database: 'arafathfruitscenter',
    });

    let latestMessageTime = 0; // Store the timestamp of the latest processed message

    setInterval(async () => {
      const [rows] = await connection.query(`
        SELECT m.conversation_id, m.from_id, m.message, UNIX_TIMESTAMP(m.created_time) AS timestamp
        FROM messages m
        JOIN (
          SELECT conversation_id, MAX(created_time) AS latest_message_time
          FROM messages
          WHERE from_name != 'Arafath Fruits Center'
          GROUP BY conversation_id
        ) l ON m.conversation_id = l.conversation_id AND m.created_time = l.latest_message_time
        WHERE m.from_name != 'Arafath Fruits Center' AND UNIX_TIMESTAMP(m.created_time) > ?
        ORDER BY l.latest_message_time DESC
      `, [latestMessageTime]);
      for (let i = 0; i < rows.length; i++) {
        const message = rows[i].message;
        if (!message) {
          // Skip empty messages
          continue;
        }
        const conversationId = rows[i].conversation_id;
        const fromId = rows[i].from_id;
        if (fromId !== '6004074063017937') {
          // Skip messages from other users
          continue;
        }
        const session = dialogFlowClient.projectAgentSessionPath(
          'chatterchatbot-bfhx',
          conversationId
        );
        const request = {
          session,
          queryInput: {
            text: {
              text: message,
              languageCode: 'en',
            },
          },
        };
        const [response] = await dialogFlowClient.detectIntent(request);
        const botResponse = response.queryResult.fulfillmentText;
        //console.log(`Conversation ID ${conversationId} [${fromId}]: ${message}`);
        //console.log(`Bot Response: ${botResponse}`);

        // Check if staff is offline for this conversation ID
        const [assignedChatsRows] = await connection.query(`
          SELECT staff_name FROM assigned_chats WHERE conversation_id = ?
        `, [conversationId]);
        if (assignedChatsRows.length > 0) {
          const staffName = assignedChatsRows[0].staff_name;
          const [staffDetailsRows] = await connection.query(`
            SELECT status FROM staff_details WHERE username = ?
          `, [staffName]);
          if (staffDetailsRows.length > 0 && staffDetailsRows[0].status === 'Offline') {
            // Send bot response as message using Facebook Graph API
            const pageId = '107834827812083';
            const pageAccessToken = 'EAAzMmo2bSDUBAPERC5WfFxAnZAdiLYxSlpRdpbxeuCCLkDWZC32nQOBdf5UWGBl3emWrZBCaUIkZCB4HTfkDyqj7OTiAH4OUaW4Ce0kWdeEhG35ihs2GYn0s8JiRu7WnqOdFrJUZBvFZB69NJvtZCiVeYRY616TeGmf0ZCFB4FK9VuRqZCY7Wq6lyq5SInZCY72eAZD';
            const recipientId = '6004074063017937';
            const apiUrl = `https://graph.facebook.com/v13.0/${pageId}/messages`;
            const message = { text: botResponse };
            const requestBody = {
              recipient: { id: recipientId },
              message: message,
              messaging_type: 'RESPONSE',
            };
            const config = {
              headers: { 'Authorization': `Bearer ${pageAccessToken}` }
            };
            await axios.post(apiUrl, requestBody, config);
          }
        }
      }
    }, 30000);
  }
}

module.exports = DialogFlowBot;
