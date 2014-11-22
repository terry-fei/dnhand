var wechatApi = require('wechat').API;

var api = new wechatApi('wx3ff5c48ba9ac6552', '6e1b422de4b33e385165ab80f73492df');

/*
api.getLatestToken(function (err, accessToken) {
  if (err) {
    console.log('getAccessToken failed');
    process.exit(0);
  }
  if (accessToken) {
    console.log('getAccessToken success!');
  }
});
*/

module.exports = api;
