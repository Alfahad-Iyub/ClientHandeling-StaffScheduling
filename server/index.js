const express = require('express');
const mysql = require('mysql2/promise');
const axios = require('axios');
const moment = require('moment');
const bodyParser = require('body-parser');

const config = require('./config.js');
const { updateDatabase } = require('./updateDatabase.js');
const { updateAssignedDatabase } = require('./updateAssignedDatabase.js');
const { getAllMessages } = require('./getAllMessages.js');
const { getAssignedChatsDetails } = require('./getAssignedChatDetails.js');
const DialogFlowBot = require('./DialogFlowBot.js');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

const bot = new DialogFlowBot();
bot.run();

app.get('/messages', async (req, res) => {
  try {
    const messages = await getAllMessages();
    res.json(messages);
  } catch (error) {
    console.error('An error occurred while retrieving messages:', error);
    res.sendStatus(500);
  }
});

app.get('/assignedchatdetails', async (req, res) => {
  try {
    const assignedchats = await getAssignedChatsDetails();
    res.json(assignedchats);
  } catch (error) {
    console.error('An error occurred while retrieving messages:', error);
    res.sendStatus(500);
  }
});

app.get('/', (req, res) => {
  res.send('Data updating successfully');
});

const pool = mysql.createPool(config);

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const [staffRows] = await pool.execute(
      'SELECT * FROM staff_details WHERE username = ? AND password = ?',
      [username, password]
    );

    if (staffRows.length > 0) {
      // Login successful
      await pool.execute(
        'UPDATE staff_details SET status = ? WHERE username = ?',
        ['Online', username]
      );

      // Insert a new row in staff_shift_tracker table
      const staffId = staffRows[0].id;
      const loginTime = new Date();
      const insertResult = await pool.execute(
        'INSERT INTO staff_shift_tracker (staff_id, login_time) VALUES (?, ?)',
        [staffId, loginTime]
      );

      const shiftId = insertResult[0].insertId;

      res.send({
        message: 'Login successful',
        shiftId: shiftId
      });
    } else {
      // Login failed
      res.status(401).send({ message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).send({ message: 'Server error' });
  }
});

app.post('/logout', async (req, res) => {
  const { username } = req.body;

  try {
    // Get the staff_id from the staff_details table using the username
    const [rows] = await pool.execute(
      'SELECT id FROM staff_details WHERE username = ?',
      [username]
    );
    const staffId = rows[0].id;

    // Update the staff_details table to set the status as 'Offline'
    await pool.execute(
      'UPDATE staff_details SET status = "Offline" WHERE username = ?',
      [username]
    );

    // Get the login_time from the staff_shift_tracker table
    const [loginRows] = await pool.execute(
      'SELECT login_time FROM staff_shift_tracker WHERE staff_id = ? AND logout_time IS NULL',
      [staffId]
    );
    const loginTime = loginRows[0].login_time;

    // Update the staff_shift_tracker table to set the logout_time and total_work_time
    const currentTime = new Date();
    const totalWorkTime = currentTime.getTime() - loginTime.getTime(); // get the difference in milliseconds
    const hours = Math.floor(totalWorkTime / 3600000); // 1 hour = 3600000 milliseconds
    const minutes = Math.floor((totalWorkTime % 3600000) / 60000); // 1 minute = 60000 milliseconds
    const seconds = Math.floor(((totalWorkTime % 3600000) % 60000) / 1000); // 1 second = 1000 milliseconds
    const totalWorkTimeFormatted = hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0'); // format the time as hh:mm:ss
    await pool.execute(
      'UPDATE staff_shift_tracker SET logout_time = ?, total_work_time = TIME_FORMAT(?, "%H:%i:%s") WHERE staff_id = ? AND logout_time IS NULL',
      [currentTime, totalWorkTimeFormatted, staffId]
    );


    res.send({ message: 'Logout successful' });
  } catch (err) {
    console.error(err);
    res.status(500).send({ message: 'Server error' });
  }
});

// API to update the assigned_chats table
app.post('/assign_chat', (req, res) => {
  const conversationId = req.body.conversationId;
  const username = req.body.username;

  pool.query('UPDATE assigned_chats SET staff_name = ?, status = "pending" WHERE conversation_id = ?', [username, conversationId])
    .then(result => {
      res.status(200).json({ message: 'Assigned chat updated successfully' });
    })
    .catch(error => {
      console.error(error);
      res.status(500).json({ message: 'Error updating assigned chats' });
    });
});

app.post('/complete_chat', (req, res) => {
  const conversationId = req.body.conversationId;
  const username = req.body.username;

  pool.query('UPDATE assigned_chats SET status = "completed" WHERE conversation_id = ? AND staff_name = ?', [conversationId, username])
    .then(result => {
      if (result.affectedRows > 0) {
        res.status(200).json({ message: 'Completed chat updated successfully' });
      } else {
        res.status(404).json({ message: 'Conversation not found or staff name does not match' });
      }
    })
    .catch(error => {
      console.error(error);
      res.status(500).json({ message: 'Error updating assigned chats' });
    });
});

app.listen(3000, () => {
  console.log('Server started on port 3000');
  setInterval(() => {
    updateDatabase();
    getAllMessages();
    updateAssignedDatabase();
  }, 10000); //refresh rate
});