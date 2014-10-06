var mailer = require('nodemailer');
var util = require('util');
var wechatApi = require('./wechat');

var transport = mailer.createTransport('SMTP', {
    service: "QQex",
    auth: {
      user: "dnhand@feit.me",
      pass: "feiteng708"
    }
});

/**
 * Send an email
 * @param {Object} data 邮件对象
 */
var sendMail = function (data) {
  transport.sendMail(data, function (err) {
    if (err) {
      // 写为日志
      console.log(err);
    }
  });
};

exports.sendErrorMail = function (title, err) {
  var templateId = '9v8rmU1Zga3JM_eEEpCRRcah4y4ZMYAVMmkpRkjoJ34';
  var url = '';
  var topColor = '';
  var data = {
    first: {
      value: title,
      color: '#173177'
    },
    time: {
      value: new Date().toString(),
      color: '#173177'
    },
    ip_list: {
      value: 'tencent dnhand',
      color: '#173177'
    },
    sec_type: {
      value: '内部服务出错',
      color: '#173177'
    },
    remark: {
      value: err.message || err,
      color: '#173177'
    }
  };
  var openid = 'oMGv_jr1BwEfyJ-ma7Y9jDHwpz8k';
  wechatApi.sendTemplate(openid, templateId, url, topColor, data, function () {});
};

exports.sendErrorMail2 = function (title, err) {
  var from = util.format('%s <%s>', '东农助手', 'dnhand@feit.me');
  var to = '13027722@qq.com';
  var subject = title;
  var content;
  if (err.message) {
    content = err.message
  } else {
    content = err
  }
  var text = content;
  sendMail({
    from: from,
    to: to,
    subject: subject,
    text: text
  });
};
