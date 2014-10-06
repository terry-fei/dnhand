

api = require '../wechat'

menu = '{
  "button":[
    {
      "type":"click",
      "name":"意见反馈",
      "key":"fankui"
    },
    {
      "name":"信息服务",
      "sub_button":[
        {
          "type":"click",
          "name":"新闻订阅",
          "key":"xwdy"
        },
        {
          "type":"click",
          "name":"锐捷",
          "key":"ruijie"
        },
        {
          "type":"click",
          "name":"剩余时长",
          "key":"sysc"
        },
        {
          "type":"click",
          "name":"考试查询",
          "key":"exam"
        }
        ]
    },
    {
      "name":"Me",
      "sub_button":[
        {
          "type":"click",
          "name":"上学期成绩",
          "key":"nowgrade"
        },
        {
          "type":"click",
          "name":"全部成绩",
          "key":"allgrade"
        },
        {
          "type":"click",
          "name":"不及格成绩",
          "key":"bjggrade"
        },
        {
          "type":"click",
          "name":"今天课表",
          "key":"todaysyllabus"
        },
        {
          "type":"click",
          "name":"全部课表",
          "key":"allsyllabus"
        }]
      }
  ]
}'

api.createMenu menu, (err, ret) ->
  console.log  err || "dnhand menu ok \n #{ret.errmsg}"
