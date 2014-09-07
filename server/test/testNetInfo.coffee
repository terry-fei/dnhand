netInfo = require '../controllers/netInfo'

#ticket = 'cdbhwR0kollePeRHEdOFu'
ticket = 'abduonwxXmaexgjgmOpHu'

getProfile = () ->
  netInfo.getProfile ticket, (err, profile) ->
    console.log profile

getSyllabus = () ->
  netInfo.getSyllabus ticket, (err, syllabus) ->
    console.error err if err
    console.dir syllabus

getGrade = () ->
  netInfo.getGrade ticket, 'qb', (err, grade) ->
    console.error err if err
    console.dir grade

#230223199505182321 cet4
getCetNumByIdcard = () ->
  netInfo.getCetNumByIdcard '230223199505182321', (err, url) ->
    console.log(url || err.message)
    
getCetGrade = () ->
  netInfo.getCetGrade '230280141115023', '杨雪额', (err, result) ->
    console.log result || err

getCetGrade()
