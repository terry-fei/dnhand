_ = require 'lodash'
Then = require 'thenjs'
cheerio = require 'cheerio'
{JwcRequest} = require '../lib/request'

syllabustDao = require('../models').Syllabus

class Syllabus
  constructor: (@stuid, @jwcRequest) ->

  @syllabusItemKeys    = ["pyfa", "kch", "kcm", "kx", "xf", "kcsx", "kslx", "js", "xdfs", "xkzt"]
  @syllabusItemSubKeys = ["zc", "xq", "jc", "jieshu", "xiaoqu", "jsl", "js"]

  @_filterClassNum = (item, m, weekDay) ->
    switch m.jc
      when '1' then Syllabus._fillSyllabusItem(weekDay, 1, item, m)
      when '3' then Syllabus._fillSyllabusItem(weekDay, 2, item, m)
      when '5' then Syllabus._fillSyllabusItem(weekDay, 3, item, m)
      when '7' then Syllabus._fillSyllabusItem(weekDay, 4, item, m)
      when '9' then Syllabus._fillSyllabusItem(weekDay, 5, item, m)
      when '11' then Syllabus._fillSyllabusItem(weekDay, 6, item, m)

  @_fillSyllabusItem = (weekDay, num, item, m) ->
    course = {
      name    :item.kcm
      teacher :item.js
      week    :m.zc
      room    :m.js
      building: m.jsl
      credit: item.xf
    }
    if weekDay[num] then weekDay[num].push course else weekDay[num] = [course]

  getSyllabusByTicket: (callback) =>
    unless @jwcRequest
      return callback new Error 'please do not instance this class directly'

    Then (cont) =>

      @jwcRequest.get JwcRequest.SYLLABUS, cont

    .then (cont, syllabusHtml) =>

      unless !!~ syllabusHtml.indexOf("历年学期课")
        err = new Error('history syllabus wrong page')
        return cont err

      # 解析html， 取得Syllabus对象
      items = []
      $ = cheerio.load(syllabusHtml)

      $("#user .odd").each ->
        temp = $(@).children("td")
        if temp.length is 17
          item = []
          itemSub = []
          temp.each (index, ele) ->
            if index < 10
              item.push($(ele).text().trim())
            else
              itemSub.push($(ele).text().trim())
          itemObj = _.zipObject(Syllabus.syllabusItemKeys, item)
          itemObj.msg = []
          itemObj.msg.push(_.zipObject(Syllabus.syllabusItemSubKeys, itemSub))
          items.push(itemObj)
        else
          itemSub = []
          temp.each ->
            itemSub.push($(@).text().trim())
          items[items.length-1].msg.push(_.zipObject(Syllabus.syllabusItemSubKeys, itemSub))

      syllabus = 1: {}, 2: {}, 3: {}, 4: {}, 5: {}, 6: {}
      syllabus.stuid = @stuid
      syllabus.length = 6

      unassigned = []

      for item in items
        for m in item.msg
          xq = Number(m.xq)
          if xq > 0 and xq < 7
            Syllabus._filterClassNum(item, m, syllabus[xq])
          else
            unassigned.push {
              name    :item.kcm
              credit  :item.xf
              teacher :item.js
            }

      # 挂载未分配的科目
      unless unassigned.length is 0
        syllabus[0] = unassigned
        syllabus.length = 7

      callback null, syllabus

    .fail (cont, err) ->
      callback err

  @updateSyllabus: (syllabus, callback) ->
    syllabustDao.findOneAndUpdate {stuid: syllabus.stuid}, syllabus, {upsert: true}, callback

  @get: (stuid, field, callback) ->
    syllabustDao.findOne {stuid: stuid}, field, callback

module.exports = Syllabus
