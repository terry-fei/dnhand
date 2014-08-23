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

getSyllabus()