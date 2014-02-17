class app.views.SaveView extends Backbone.View
  initialize: ->
    @model.on('change:uploadFinish', @handleFinish, this)

  events:
    'tap .back-button': 'back'
    'tap .save-button': 'beforeSave'
    'tap .sign-in-button': 'signIn'
    'tap .no-sign-in-button': 'saveWithoutSignIn'

  render: ->
    @$el.html @template(@options.data)
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  beforeSave: (event)->
    event.preventDefault()
    event.stopPropagation()
    auth_token = window.localStorage.getItem('auth_token')
    unless auth_token
      @navigate()
#      window.localStorage.setItem 'sign_in_callback', window.location.hash.replace('#', '')
#      window.location.hash = 'sign_in'
    else
      @save()

  navigate: ->
    console.log 'navigate: (event)->'
    #    event.preventDefault()
    #    event.stopPropagation()
    container = $('#st-container')

    # Show
    unless container.hasClass('st-menu-open')
      container.addClass('st-effect-1')
      container.addClass('st-menu-open')
      $(document).on 'tap', $.proxy(@bodyClickFn, this)
    else
      container.removeClass('st-effect-1')
      container.removeClass('st-menu-open')

  hasParentClass: (e, classname) ->
    return false  if e is document
    return true  if classie.has(e, classname)
    e.parentNode and @hasParentClass(e.parentNode, classname)

  bodyClickFn: (evt) ->
    unless @hasParentClass(evt.target, 'st-menu')
      container = $('#st-container')
      container.removeClass('st-menu-open')
      container.removeClass('st-effect-1')
      $(document).off 'tap', @bodyClickFn

  signIn: ->
    @navigate()
    window.localStorage.setItem 'sign_in_callback', window.location.hash.replace('#', '')
    window.location.hash = 'sign_in'

  saveWithoutSignIn: ->
    @navigate()
    @save()

  save: ->
    $('.ui-loader').show()
    @user_id = window.localStorage.getItem('user_id')
    @user_id = '0' unless @user_id
    @message = window.localStorage.getItem('message')
    self = this
    app.appRootDir.getDirectory @user_id,
      create: true
      exclusive: false
    , (userEntry)->
      # save card
      self.saveCardFile userEntry
    , ->
      console?.log 'failed to create user folder.'

  saveCardFile: (userEntry)->
    self = this
    userEntry.getDirectory 'card',
      create: true
      exclusive: false
    , (cardEntry) ->
      self.image_url = window.localStorage.getItem('image_url')
      window.resolveLocalFileSystemURI self.image_url, (fileEntry)->
        fileEntry.moveTo cardEntry, fileEntry.name, (entry) ->
          self.image_url = entry.fullPath
          self.image_file_entry = entry
          console?.log 'save image to ' + entry.fullPath
          # save audio
          self.audio_url = window.localStorage.getItem('audio_url')
          if self.audio_url then self.saveAudioFile userEntry else self.saveDatabase()
        , ->
          console?.log 'moveTo failed:' + cardEntry.fullPath
      , ->
        console?.log 'resolveLocalFileSystemURI failed:' + self.image_url
    , ->
      console?.log 'failed to create card folder.'

  saveAudioFile: (userEntry)->
    self = this
    userEntry.getDirectory 'audio',
      create: true
      exclusive: false
    , (audioEntry) ->
      window.resolveLocalFileSystemURI self.audio_url, (fileEntry)->
        fileEntry.moveTo audioEntry, fileEntry.name, (entry) ->
          self.audio_url = entry.fullPath
          self.audio_file_entry = entry
          console?.log 'save audio to ' + entry.fullPath
          # save device database
          self.saveDatabase()
        , ->
          console?.log 'moveTo failed:' + audioEntry.fullPath
      , ->
        console?.log 'resolveLocalFileSystemURI failed:' + self.audio_url
    , ->
      console?.log 'failed to create audio folder.'

  saveDatabase: ->
    # save local database
    self = this
    cardDao = new app.dao.CardDAO(app.db)
    cardDao.create @user_id, @image_url, @audio_url, @message, (data)->
      console?.log 'save to local database successfully.'
      window.localStorage.removeItem('image_url')
      window.localStorage.removeItem('audio_url')
      window.localStorage.removeItem('message')
      window.localStorage.removeItem('image_data')
      window.localStorage.removeItem('image_data_width')
      window.localStorage.removeItem('image_data_height')

      if self.user_id is '0'
        app.utils.toast.showShort '本地保存成功'
        window.location.hash = 'home'
        return
      # save remote database
      self.model.set 'client_id', data.id
      self.model.uploadFile self.image_file_entry, self.audio_file_entry

  handleFinish: ->
    $('.ui-loader').hide()
    switch @model.get('uploadFinish')
      when 1
        app.utils.toast.showShort '上传成功'
        window.location.hash = 'home'
      when -1
        app.utils.toast.showShort '认证失败，请重新登录再同步到服务器'
        window.location.hash = 'sign_in'
      when -2
        app.utils.toast.showLong '连接服务器失败，可稍候同步到服务器'
        window.location.hash = 'home'
      else
