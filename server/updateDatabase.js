const axios = require('axios');
const mysql = require('mysql2/promise');
const moment = require('moment');
const config = require('./config');

const FB_ACCESS_TOKEN = "EAAzMmo2bSDUBAPERC5WfFxAnZAdiLYxSlpRdpbxeuCCLkDWZC32nQOBdf5UWGBl3emWrZBCaUIkZCB4HTfkDyqj7OTiAH4OUaW4Ce0kWdeEhG35ihs2GYn0s8JiRu7WnqOdFrJUZBvFZB69NJvtZCiVeYRY616TeGmf0ZCFB4FK9VuRqZCY7Wq6lyq5SInZCY72eAZD";

async function updateDatabase() {
  try {
    // a GET request to the Facebook API to get conversation IDs
    const conversationResponse = await axios.get(`https://graph.facebook.com/v15.0/107834827812083/conversations?platform=messenger&access_token=${FB_ACCESS_TOKEN}`);
    const conversations = conversationResponse.data.data;

    // Create a connection pool to the MySQL database
    const pool = mysql.createPool({
      ...config,
      connectionLimit: 10, // set a lower connection limit
    });

    // Loop through each conversation to get messages
    const tasks = conversations.map(async (conversation) => {
      try {
        // Make a GET request to the Facebook API to get messages for this conversation
        const messageResponse = await axios.get(`https://graph.facebook.com/v15.0/${conversation.id}?fields=messages{message,from,to,created_time}&access_token=${FB_ACCESS_TOKEN}`);
        const messages = messageResponse.data.messages.data;

        // Insert each message into the database concurrently
        const insertTasks = messages.map(async (message) => {
          try {
            const createdTime = moment(message.created_time).format('YYYY-MM-DD HH:mm:ss');
            await pool.execute(
              `INSERT INTO messages (conversation_id, message_id, message, from_name, from_id, created_time)
               VALUES (?, ?, ?, ?, ?, ?)`,
              [
                conversation.id,
                message.id,
                message.message || null,
                (message.from && message.from.name) || null,
                (message.from && message.from.id) || null,
                createdTime,
              ]
            );
          } catch (err) {
            if (err.code !== 'ER_DUP_ENTRY') {
              throw err;
            }
          }
        });
        await Promise.all(insertTasks);
      } catch (error) {
        console.error('Error retrieving messages from Facebook API:', error);
        throw error;
      }
    });

    // Wait for all tasks to complete and release the connection pool
    await Promise.all(tasks);
    await pool.end();
    return true;
  } catch (error) {
    console.error('An error occurred while updating the database:', error);
    return false;
  }
};

module.exports = {
  updateDatabase,
};