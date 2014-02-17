Date::Format = (fmt) -> #author: meizz
  o =
    "M+": @getMonth() + 1 #月份
    "d+": @getDate() #日
    "h+": @getHours() #小时
    "m+": @getMinutes() #分
    "s+": @getSeconds() #秒
    "q+": Math.floor((@getMonth() + 3) / 3) #季度
    S: @getMilliseconds() #毫秒

  fmt = fmt.replace(RegExp.$1, (@getFullYear() + "").substr(4 - RegExp.$1.length))  if /(y+)/.test(fmt)
  for k of o
    fmt = fmt.replace(RegExp.$1, (if (RegExp.$1.length is 1) then (o[k]) else (("00" + o[k]).substr(("" + o[k]).length))))  if new RegExp("(" + k + ")").test(fmt)
  fmt