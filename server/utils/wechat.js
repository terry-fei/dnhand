var wechatApi = require('wechat').API;

var api = new wechatApi('wx3ff5c48ba9ac6552', 'a24c6ca520e8f40db635b3dadba6a945 ');

api.getLatestToken(function () {});

module.exports = api;
