var mailer = require('nodemailer');
var util = require('util');

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
