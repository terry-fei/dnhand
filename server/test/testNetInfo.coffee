netInfo = require '../controllers/netInfo'

#ticket = 'cdbhwR0kollePeRHEdOFu'
ticket = 'dba5hRkrdIqrha3nwoOFu'

getProfile = () ->
  netInfo.getProfile ticket, (err, profile) ->
    console.log profile

getSyllabus = () ->
  netInfo.getSyllabus ticket, (err, syllabus) ->
    console.error err.message if err
    console.log syllabus
    
#230223199505182321 cet4
getCetNumByIdcard = () ->
  netInfo.getCetNumByIdcard '230223199505182321', (err, url) ->
    console.log(url || err.message)
    
getCetGrade = () ->
  netInfo.getCetGrade '230280141115023', '杨雪', (err, result) ->
    console.log result || err

getCetGrade()
