const axios = require('axios');

const getUserProfile = async (accessToken) => {
  const fields = 'first_name,last_name,email,birthday,gender,profile_pic';
  const url = `https://graph.facebook.com/v16.0/me?fields=${fields}&access_token=${accessToken}`;

  try {
    const response = await axios.get(url);
    return response.data;
  } catch (error) {
    console.error(error);
  }
};

module.exports = { getProfileDetails };