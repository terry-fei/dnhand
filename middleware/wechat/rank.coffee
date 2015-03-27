Then = require 'thenjs'

{zyGrade} = require '../../models'


module.exports =
  getRank: (info, req, res) ->
    stuid = info.user.stuid

    student = null
    Then (next) ->
      zyGrade.findOne {stuid: stuid}, next

    .then (next, studentIns) ->
      student = studentIns

      query =
        majorName: student.majorName
        majorYear: student.majorYear
        clsNo: student.clsNo
      zyGrade.find(query).count(next)

    .then (next, clsCount) ->
      student.clsCount = clsCount

      query =
        majorName: student.majorName
        majorYear: student.majorYear

      zyGrade.find(query).count(next)

    .then (next, majorCount) ->
      student.majorCount = majorCount

      getRankByStudent student, next

    .then (next, clsRank) ->
      student.clsRank = clsRank + 1

      student.clsNoBac = student.clsNo
      student.clsNo = 0
      getRankByStudent student, next

    .then (next, majorRank) ->
      majorRank += 1

      majorYear = student.majorYear
      clsNo = student.clsNoBac
      result = """
        #{student.name}
        #{student.majorName}专业 #{majorYear}级 #{clsNo}班

        你们班共有 #{student.clsCount} 人
        你的班级排名 #{student.clsRank}

        #{student.majorName}专业共有 #{student.majorCount} 人
        你的专业排名 #{majorRank}
      """

      res.reply result

    .fail (next, err) ->
      console.trace err

getRankByStudent = (student, callback) ->
  query =
    majorName: student.majorName
    majorYear: student.majorYear

  if student.clsNo
    query.clsNo = student.clsNo

  zyGrade.find(query)
  .where('zyGrade').gt(student.zyGrade)
  .count().exec(callback)
