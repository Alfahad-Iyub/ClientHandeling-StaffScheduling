const axios = require('axios');
const mysql = require('mysql2/promise');
const moment = require('moment');
const config = require('./config');

const FB_ACCESS_TOKEN = "EAAzMmo2bSDUBAPERC5WfFxAnZAdiLYxSlpRdpbxeuCCLkDWZC32nQOBdf5UWGBl3emWrZBCaUIkZCB4HTfkDyqj7OTiAH4OUaW4Ce0kWdeEhG35ihs2GYn0s8JiRu7WnqOdFrJUZBvFZB69NJvtZCiVeYRY616TeGmf0ZCFB4FK9VuRqZCY7Wq6lyq5SInZCY72eAZD";

// Create a connection pool to the MySQL database
const pool = mysql.createPool({
  ...config,
  connectionLimit: 10, // Set the maximum number of connections
});

async function updateAssignedDatabase() {
  let connection;
  try {
    // Acquire a connection from the pool
    connection = await pool.getConnection();

    // a GET request to the Facebook API to get conversation IDs
    const conversationResponse = await axios.get(`https://graph.facebook.com/v15.0/107834827812083/conversations?platform=messenger&access_token=${FB_ACCESS_TOKEN}`);
    const conversations = conversationResponse.data.data;

    // Loop through each conversation to get messages and from names
    const tasks = conversations.map(async (conversation) => {
      try {
        // Make a GET request to the Facebook API to get messages for this conversation
        const messageResponse = await axios.get(`https://graph.facebook.com/v15.0/${conversation.id}?fields=messages{from}&access_token=${FB_ACCESS_TOKEN}`);
        const messages = messageResponse.data.messages.data;

        // Get the unique from names for this conversation
        const fromNames = [...new Set(messages.map(message => message.from.name))];

        // Insert each from name into the database if it's not 'Arafath Fruits Center'
        const insertTasks = fromNames
          .filter(fromName => fromName !== 'Arafath Fruits Center')
          .map(async (fromName) => {
            try {
              await connection.execute(
                `INSERT IGNORE INTO assigned_chats (conversation_id, from_name) VALUES (?, ?)`,
                [conversation.id, fromName]
              );
            } catch (err) {
              console.error('Error inserting into assigned_chats table:', err);
              throw err;
            }
          });
        await Promise.all(insertTasks);
      } catch (error) {
        console.error('Error retrieving messages from Facebook API:', error);
        throw error;
      }
    });

    // Wait for all tasks to complete
    await Promise.all(tasks);
    return true;
  } catch (error) {
    console.error('An error occurred while updating the database:', error);
    return false;
  } finally {
    // Release the connection back to the pool
    if (connection) {
      connection.release();
    }
  }
};

module.exports = {
  updateAssignedDatabase,
};
