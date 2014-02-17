app.utils.screenshot =
  capture: (success, fail, directory)->
    params =
      directory: directory

    PhoneGap.exec(success, fail, "Screenshot", "saveScreenshot", [params])
