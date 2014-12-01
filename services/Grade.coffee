_ = require 'lodash'
cheerio = require 'cheerio'
Then = require 'thenjs'
{JwcRequest} = require '../lib/request'

class Grade
  constructor: (@stuid, @jwcRequest) ->

  @GRADE_KEYS:
    # 本学期成绩
    bxq: ['kch', 'kxh', 'kcm', 'ywkcm', 'xf', 'cksx', 'kczgf', 'kczdf', 'kxpjf', 'cj', 'mc', 'wtgyy']

    # 不及格成绩
    bjg: ['kch', 'kxh', 'kcm', 'ywkcm', 'xf', 'cksx', 'cj', 'kssj', 'wtgyy']

    # 方案全部成绩
    fa: ['kch', 'kxh', 'kcm', 'ywkcm', 'xf', 'cksx', 'cj', 'wtgyy']

    # 全部及格成绩
    qb: ['kch', 'kxh', 'kcm', 'ywkcm', 'xf', 'cksx', 'cj']

    # 课程属性成绩
    kcsx: ['kch', 'kxh', 'kcm', 'ywkcm', 'xf', 'cksx', 'cj', 'wtgyy']

  getGradeByTicket: (type, callback) ->
    unless @jwcRequest
      return callback new Error 'please do not instance this class directly'

    url = JwcRequest.GRADE_URLS[type]
    keys = Grade.GRADE_KEYS[type]

    unless url and keys
      return callback new Error 'check grade type, more info at lib/request.coffee'

    Then (cont) =>

      @jwcRequest.get url, cont

    .then (cont, gradeHtml) ->

      unless !!~ gradeHtml.indexOf("课程")
        err = new Error('wrong page')
        return cont err

      $ = cheerio.load(gradeHtml)

      if type is 'bjg'
        groupNames = ['尚不及格', '曾不及格']

      else
        groupNames = []
        title = $("#tblHead")
        title.each ->
          groupNames.push($(@).text().trim().replace('.', ''))

      table = $("#user")
      group = []
      table.each ->
        items = []
        cheerio(@).find("tr.odd").each ->
          values = []
          cheerio(@).children("td").each ->
            values.push(cheerio(@).text().trim())
          items.push(_.zipObject(keys, values))
        group.push(items)
      callback null, _.zipObject(groupNames, group)

    .fail callback

module.exports = Grade
