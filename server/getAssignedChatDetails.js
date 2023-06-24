const mysql = require('mysql2/promise');
const config = require('./config');

async function getAssignedChatsDetails() {
  try {
    // Create a connection pool to the MySQL database
    const pool = mysql.createPool(config);

    // Query the database to get all messages
    const [rows, fields] = await pool.execute(
      `SELECT * FROM assigned_chats`
    );

    // Release the connection pool
    await pool.end();

    // Return the results
    return rows;
  } catch (error) {
    console.error('An error occurred while retrieving messages from the database:', error);
    return null;
  }
};

module.exports = { getAssignedChatsDetails };
