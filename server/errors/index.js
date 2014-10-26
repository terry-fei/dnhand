var _ = require('lodash');
var path = require('path');
var Logger = require('mini-logger');
var logger = Logger({
  dir: path.join(__dirname, 'logs'),
  categories: [ 'http' ],
  stdout: true,
  format: '[{category}.]YYYY-MM-DD[.log]'
});

var mailer = require('../utils/mailer');
var wechatApi = require('../utils/wechat');
var adminOpenid = 'oMGv_jr1BwEfyJ-ma7Y9jDHwpz8k';

var errorHandler = function (error) {
  if (!error) {
    return;
  }

  if (_.isString(error)) {
    error = new Error(error);
  }

  if (error.openid) {
    wechatApi.sendText(error.openid, '发生错误，请稍候再试', errorHandler)
  }

  if (_.contains(error.name, 'WeChat')) {
    mailer.sendErrMail('WeChatApi Error', error);
  }

  logger.error(error);
};

module.exports.errorHandler = errorHandler;
