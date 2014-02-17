app.utils.notification =
  showAlert: (message, title)->
    if navigator.notification
      navigator.notification.alert message, null, title, "OK"
    else
      alert (if title then (title + ": " + message) else message)

  changePicture: (event) ->
    event.preventDefault()
    unless navigator.camera
      @showAlert "Camera API not supported", "Error"
      return
    options =
      quality: 50
      destinationType: Camera.DestinationType.DATA_URL
      sourceType: 1 # 0:Photo Library, 1=Camera, 2=Saved Photo Album
      encodingType: 0 # 0=JPG 1=PNG

    navigator.camera.getPicture ((imageData) ->
      $(".employee-image", @el).attr "src", "data:image/jpeg;base64," + imageData
    ), (->
      @showAlert "Error taking picture", "Error"
    ), options
    false