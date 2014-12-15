ejs = require('ejs')

subscribeStr = """
Hi， <%- name %>
基本功能在下方的按钮中
除此之外 还有以下指令
【绑定】更换绑定的学号
【期末】查看期末考试安排
【补考】查看补考安排
【准考证】四六级准考证
"""

module.exports.subscribe = ejs.compile(subscribeStr)
