info = require('../controllers/info')

getProfileByStuid = () ->
  info.getProfileByStuid 'A19120626', (err, ins) ->
    console.log(new Date() - ins.update_time)

getProfileByOpenid = () ->
  info.getProfileByOpenid 'oMGv_jmv6RM6t1LPXaKKpbHDdYps', (err, ins) ->
    console.log ins

isBand = () ->
  info.isBind 'oMGv_jmv6RM6t1LPXaKKpbHDdYps', (err, ins) ->
    console.log ins

updateStudentPswd = () ->
  info.updateStudentPswd '123', '456', (err, ins) ->
    console.log ins

getQbGrade = () ->
  info.getQbGrade 'A19120626', (err, grade) ->
    console.log grade['qb']['2013-2014学年春(两学期)']
    process.exit(1)

getRank = () ->
  info.getRank 'A19120626', (err, student) ->
    console.log err || student
    process.exit(1)

getRank()