app.utils.toast =
  showShort: (message, success, fail)->
    PhoneGap.exec(success, fail, "ToastPlugin", "show_short", [message])

  showLong: (message, success, fail)->
    PhoneGap.exec(success, fail, "ToastPlugin", "show_long", [message])
