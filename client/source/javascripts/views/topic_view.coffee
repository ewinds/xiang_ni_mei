class app.views.TopicView extends Backbone.View
  events:
    "tap #back-button": "back"
    "tap .camera-toggle": "toggle"
    "tap #over-screen-nav-button": "navigate"
    "tap #over-screen-nav-close": "navigate"
    "tap #microphone-button": "captureAudio"
    "tap #trash-button": "delete"
    "tap #open-camera-button": "openCamera"
    "tap #open-lib-button": "openLib"
    'tap #next-button': 'prepareScreenshot'

  render: ->
    @$el.html @template(@model.toJSON())
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  toggle: ->
    $('.camera').toggle()

  navigate: (event)->
    console.log 'navigate: (event)->'
    event.preventDefault()
    event.stopPropagation()
    container = $('#st-container')

    # Show
    unless container.hasClass('st-menu-open')
      container.addClass('st-effect-1')
      container.addClass('st-menu-open')
      $(document).on 'tap', $.proxy(@bodyClickFn, this)
    else
      container.removeClass('st-effect-1')
      container.removeClass('st-menu-open')

  playReady: ->
    microphoneIcon = @$('.icon-microphone')
    microphoneIcon.removeClass('icon-microphone')
    microphoneIcon.addClass('icon-play')
    @trashToggle()

  trashToggle: ->
    trash = @$('.trash')
    trash.toggle()

  captureAudio: ->
    unless @audioUrl
      # Launch device audio recording application,
      # allowing user to capture up to 1 audio clips
      #
      navigator.device.capture.captureAudio $.proxy(@onAudioSuccess, this), $.proxy(@onAudioFail, this),
        limit: 1,
        duration: 30
    else
      url = decodeURIComponent(@audioUrl)
      console?.log 'prepare to play:' + url
      my_media = new Media(url, ->
        console?.log "playAudio():Audio Success"
      , (err) ->
        console?.log "playAudio():Audio Error: " + err
      )

      # Play audio
      my_media.play()

  onAudioSuccess: (mediaFiles) ->
    i = undefined
    len = undefined
    i = 0
    len = mediaFiles.length
    self = this

    while i < len
      console?.log mediaFiles[i].fullPath
      fullPath = decodeURIComponent mediaFiles[i].fullPath
      extension = fullPath.substring(fullPath.lastIndexOf('.') + 1)
      parentEntry = new DirectoryEntry(app.appRootDirName, app.appRootDir.fullPath)
      fileName = (new Date()).getTime() + '.' + extension
      console.log(JSON.stringify(parentEntry))
      window.resolveLocalFileSystemURI fullPath, (fileEntry)->
        fileEntry.moveTo parentEntry, fileName, (entry)->
          self.audioUrl = entry.fullPath
          window.localStorage.setItem 'audio_url', entry.fullPath
          self.playReady()
        , (error)->
          app.utils.toast.showShort 'moveTo failed:' + error.code
      , (event)->
        app.utils.toast.showShort 'resolveLocalFileSystemURI failed:' + event.target.error.code
      i += 1
  onAudioFail: (error) ->
    if error.code is 3
      app.utils.toast.showShort '已取消'
    else
      app.utils.toast.showShort '请重试'

  delete: ->
    microphoneIcon = @$('.icon-play')
    microphoneIcon.removeClass('icon-play')
    microphoneIcon.addClass('icon-microphone')
    @audioUrl = null
    @trashToggle()

  openCamera: ->
    sourceType = Camera.PictureSourceType.CAMERA
    @capturePicture sourceType
  openLib: ->
    console.log 'openLib: ->'
    sourceType = Camera.PictureSourceType.PHOTOLIBRARY
    @capturePicture sourceType

  capturePicture: (sourceType)->
    @$('#over-screen-nav-close').trigger 'tap'
    navigator.camera.getPicture $.proxy(@onPhotoSuccess, this), $.proxy(@onPhotoFail, this),
      quality: 70
      sourceType: sourceType
      destinationType: Camera.DestinationType.FILE_URI
      targetWidth: 960
      targetHeight: 720
      correctOrientation: true

  onPhotoSuccess: (imageUri)->
    @$('#next-button').removeClass('is-disabled')
    photo = @$('#picture')
    photo.attr 'src', imageUri
    console?.log 'image data:' + imageUri
    coverImage = @$('.cover-image')
    #    imageWrapper = @$('.image-wrapper')
    draggableImage = @$('.draggable-image')
    imageContainer = @$('.image-container')

    draggableImage.css
      left: Math.round(coverImage.width() * 0.1)
      top: Math.round(coverImage.width() * 0.1)
      width: Math.round(coverImage.width() * 0.8)

    imageContainer.css
      width: Math.round(coverImage.width() * 0.8)

    # Prevent losing image quality
    #
    photo.css
      width: Math.round(coverImage.width() * 0.8) * 2

    draggableImage.css
      '-webkit-transform': 'scale3d(0.5, 0.5, 1)'
      '-webkit-transform-origin': '0 0'

    zoomView = new app.views.ZoomView('.draggable-image', '.image-container', '.camera-toggle')

  onPhotoFail: (message)->
    console.log message

  # Fot testing in browser
  #
  toggleWatchDog: ->
    Hammer.plugins.fakeMultitouch()  if not Hammer.HAS_TOUCHEVENTS and not Hammer.HAS_POINTEREVENTS
    @onPhotoSuccess('images/pic1.jpg')

  prepareScreenshot: ->
    @$('#back-button').hide()
    @$('#next-button').hide()
    @$('.camera').hide()
    @$('.microphone').hide()
    @$('.trash').hide()

    greeting =@$('#greeting')
    if greeting.val() is ''
      greeting.val(' ')
    else
      window.localStorage.setItem 'message', greeting.val()

    setTimeout $.proxy(->
      @screenshot()
    , this), 200
    this

  screenshot: ->
    app.utils.screenshot.capture $.proxy(@onScreenshotSuccess, this), $.proxy(@onScreenshotFail,
      this), app.appRootDir.fullPath

  onScreenshotSuccess: (data)->
#    photo = @$('#picture')
#    photo.attr 'src', 'data:image/jpeg;base64,' + data.imageData
    console?.log 'screenshotImage:' + data.width + 'X' + data.height
    window.localStorage.setItem 'image_data', data.imageData
    window.localStorage.setItem 'image_data_width', data.width
    window.localStorage.setItem 'image_data_height', data.height
    window.localStorage.setItem 'image_url', data.url
    window.location.hash = 'topics/' + @model.id + '/save'

  onScreenshotFail: (message) ->
    app.utils.toast.showShort message

  hasParentClass: (e, classname) ->
    return false  if e is document
    return true  if classie.has(e, classname)
    e.parentNode and @hasParentClass(e.parentNode, classname)

  bodyClickFn: (evt) ->
    unless @hasParentClass(evt.target, "st-menu")
      container = $('#st-container')
      container.removeClass('st-menu-open')
      container.removeClass('st-effect-1')
      $(document).off 'tap', @bodyClickFn




