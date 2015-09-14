{zyGrade} = require '../models'

grades = require './grades.json'

zyGrade.create grades, (err) ->
  console.error err if err
  console.log 'done'
