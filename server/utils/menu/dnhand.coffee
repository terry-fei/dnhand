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
      "name":"由你做主",
      "key":"youni"
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
        }]
    },
    {
      "name":"\ue30c My",
      "sub_button":[
        {  
          "type":"click",
          "name":"本学期",
          "key":"nowgrade"
        },
        {
          "type":"click",
          "name":"全部成绩",
          "key":"allgrade"
        },
        {
          "type":"click",
          "name":"考试查询",
          "key":"exam"
        }]
      }
  ]
}'