ejs = require('ejs')

subscribeStr = """
Hi， <%- name %>
基本功能在下方的按钮中
除此之外 还有以下指令
【cet】四六级成绩
【绑定】更换绑定的学号
【排名】智育成绩排名
【身份证号】四六级准考证
"""

module.exports.subscribe = ejs.compile(subscribeStr)
