

api = require '../wechat'

menu = '{
  "button":[
    {
      "type":"click",
      "name":"今天",
      "sub_button":[
        {
          "type":"view",
          "name":"口罩",
          "url":"http://shop334273.koudaitong.com/v2/showcase/feature?alias=1dv995gjg&from=groupmessage&isappinstalled=0"
        },
        {
          "type":"click",
          "name":"客服",
          "key":"fankui"
        }
      ]
    },
    {
      "name":"天气",
      "sub_button":[
        {
          "type":"view",
          "name":"绑定",
          "url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx3ff5c48ba9ac6552&redirect_uri=http://n.feit.me/wx/oauth&response_type=code&scope=snsapi_base&state=bind#wechat_redirect"
        },
        {
          "type":"click",
          "name":"锐捷",
          "key":"ruijie"
        },
        {
          "type":"click",
          "name":"新闻",
          "key":"xwdy"
        },
        {
          "type":"click",
          "name":"上网时长",
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
      "name":"不错",
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
