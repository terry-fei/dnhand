Then = require 'thenjs'
com = require './common'
ruijieMsg = require './ruijie'
gradeMsg = require './grade'
moment = require 'moment'
ruijieHelper = require '../../lib/ruijieHelper'

ImageText = com.ImageText

policyDesc =
  '50': 150
  '30': 60
  '20': 30

module.exports = (info, req, res) ->
  status = req.wxsession.status
  content = info.Content

  delStatus = (flag) ->
    req.wxsession.destroy()
    if flag then com.sendText info.FromUserName, '已返回正常模式' else res.reply '已返回正常模式'

  if /(取消|退出|返回)/.test content
    return delStatus()

  switch status
    when 'bindRuijie'
      res.reply '正在验证你的密码'
      delStatus(true)
      info.pswd = content
      ruijieMsg.bind info

    when 'cet'
      cet = req.wxsession.cet
      unless cet
        return delStatus()

      switch cet.stage
        when 'name'
          cet.name = content
          cet.stage = 'number'
          res.reply '请回复准考证号'

        when 'number'
          info.name = cet.name
          info.cetNum = content
          res.reply '正在查询，查询速度视网络情况而定'
          gradeMsg.replyCet info
          delStatus(true)

        else
          delStatus()
   
   when 'charge'
    ruijie = req.wxsession.ruijie
    unless ruijie
      return delStatus()
    
    switch ruijie.stage
      when 'value'

        if content is '1'
          res.reply 'http://wap.koudaitong.com/v2/showcase/goods?alias=dnxa1o6c&showsku=true'
          delStatus(true)
        else if content is '2'
          policy = 'http://wap.koudaitong.com/v2/showcase/goods?alias=1d5wt53ou&showsku=true'
          delStatus(true)
        else if content is '3'
          policy = 'http://wap.koudaitong.com/v2/showcase/goods?alias=m5dvhdj3&showsku=true'
          delStatus(true)
        else
          delStatus()
          return
      else
        delStatus()

    when 'changePolicy'
      ruijie = req.wxsession.ruijie

      unless ruijie
        delStatus()

      switch ruijie.stage
        when 'policy'
          if content is '1'
            policy = 20
          else if content is '2'
            policy = 30
          else if content is '3'
            policy = 50
          else
            delStatus()
            return

          ruijie.policy = policy
          ruijie.stage = 'type'

          res.reply """
            请回复编号：
            【1】立即生效
            【2】下周期生效
          """

        when 'type'

          if content is '1'
            immediately = true
            confirmStr = """
              即将办理 #{ruijie.policy} 元套餐
              含时长 #{policyDesc[ruijie.policy]} 小时，有效期1个月
              套餐将会立即生效
              新周期起始时刻：
              #{moment().format('YYYY-MM-DD HH:mm')}

              变更影响：
              当前计费周期剩余可用的时长或者流量将清零！！！
              新计费周期立即开始，将立即扣除新周期的费用！！！
              (不使用不扣费套餐除外)

              确认请回复【1】
            """

          else if content is '2'
            immediately = false
            confirmStr = """
              即将办理 #{ruijie.policy} 元套餐
              含时长 #{policyDesc[ruijie.policy]} 小时，有效期1个月
              套餐将在下周期开始时生效

              变更影响：
              新的计费策略从下周期开始时生效
              生效时扣除新周期费用

              确认请回复【1】
            """

          else
            delStatus()
            return

          ruijie.immediately = immediately
          ruijie.stage = 'confirm'

          res.reply confirmStr

        when 'confirm'
          unless content is 1
            delStatus()
            return

          delStatus(true)
          res.reply '正在变更套餐，请稍候'

          ruijie.loginResult.policy = ruijie.policy
          ruijie.immediately = ruijie.immediately
          ruijieHelper.changePolicy ruijie.loginResult, (err, result) ->
            if result.errcode is 0
              com.sendText info.FromUserName, '套餐变更成功！'

            else
              com.sendText info.FromUserName, '套餐变更失败，请检查你的余额是否充足，如充足请重试'

        else
          delStatus()

    else
      delStatus()
