var wechatApi = require('wechat').API;

var api = new wechatApi('wx3ff5c48ba9ac6552', '2715445e17a0640bc4f2a2f884a69124');

api.getLatestToken(function () {});

module.exports = api;
