var wechatApi = require('wechat').API;

var api = new wechatApi('wx3ff5c48ba9ac6552', '6e1b422de4b33e385165ab80f73492df');
api.can = true

module.exports = api;
