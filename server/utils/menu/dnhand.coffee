API = require('wechat').API

api = new API('wx3ff5c48ba9ac6552', '2e1304394b0fe6306222cefb5c22b465')

api.getAccessToken (err, ret) ->
  if err
    console.log "getAccessToken Err"
  else
    api.createMenu menu, (err, ret) ->
      console.log  err || "dnhand menu ok \n #{ret.errmsg}"

menu = '{
  "button":[
    {
      "type":"click",
      "name":"意见反馈",
      "key":"fankui"
    },
    {
      "name":"校内新闻",
      "sub_button":[
        {
          "type":"click",
          "name":"教务信息",
          "key":"jiaowu"
        },
        {
          "type":"click",
          "name":"考务信息",
          "key":"kaowu"
        },
        {
          "type":"click",
          "name":"学校公告",
          "key":"xuexiaogonggao"
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
          "name":"明天课表",
          "key":"tomorrowsyllabus"
        }]
      }
  ]
}'