const config = require('./config.js');

async function login(req, res) {
  const { username, password } = req.body;

  try {
    const [staffRows] = await config.pool.execute(
      'SELECT * FROM staff_details WHERE username = ? AND password = ?',
      [username, password]
    );

    if (staffRows.length > 0) {
      // Login successful
      await config.pool.execute(
        'UPDATE staff_details SET status = ? WHERE username = ?',
        ['Online', username]
      );

      // Insert a new row in staff_shift_tracker table
      const staffId = staffRows[0].id;
      const loginTime = new Date();
      const insertResult = await config.pool.execute(
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
}

module.exports = login;
