class app.views.CardsView extends Backbone.View
  initialize: ->
    @collections = new app.models.CardCollection()
    @collections.parent = @model
    @collections.fetch
      reset: true
    @collectionsView = new app.views.CardListView(model: @collections)

  events:
    'tap .back-button': 'back'
    'tap .synchronize-button': 'beforeSynchronize'
    'tap a': 'handleTapLink'
    'click a': 'preventDefault'

  render: ->
    @$el.html @template()
    $('.scroller', @el).append(@collectionsView.render().el)
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  handleTapLink: (e)->
    app.utils.event.handleTapLink(e)

  preventDefault: (e)->
    e.preventDefault()

  beforeSynchronize: ->
    if window.localStorage.getItem('user_id')
      @synchronize()
    else
      window.localStorage.setItem 'sign_in_callback', window.location.hash.replace('#', '')
      window.location.hash = 'sign_in'

  synchronize: ->
    console.log 'collections length:' + @collections.models.length
    console.log 'collections[1]:' + @collections.models[1].attributes.synchronized
    @unsyncs = @collections.filter (card)->
      true unless card.get('synchronized')
    @unsyncSize = _.size(@unsyncs)
    console.log 'synchronize count:' + @unsyncSize

    if @unsyncSize is 0
      app.utils.toast.showShort '同步完成'
    else
      @finish = 0
      @$('.measure').text @finish + '/' + @unsyncSize
      @card = _.first(@unsyncs)
      $('.ui-loader').show()
      @localSynchronize()

  localSynchronize: ->
    user_id = @card.get('user_id')
    if @model.id + '' isnt user_id + ''
      self = this
      app.appRootDir.getDirectory @model.id + '',
        create: true
        exclusive: false
      , (userEntry)->
        # save card
        self.saveCardFile userEntry
      , ->
        console?.log 'failed to create user folder.'
    else
      @upload()

  saveCardFile: (userEntry)->
    self = this
    userEntry.getDirectory 'card',
      create: true
      exclusive: false
    , (cardEntry) ->
      window.resolveLocalFileSystemURI self.card.get('image_url'), (fileEntry)->
        fileEntry.moveTo cardEntry, fileEntry.name, (entry) ->
          self.card.set 'image_url', entry.fullPath
          #          self.image_file_entry = entry
          console?.log 'save image to ' + entry.fullPath
          # save audio
          if self.card.get('audio_url') then self.saveAudioFile userEntry else self.saveDatabase()
        , ->
          console?.log 'moveTo failed:' + cardEntry.fullPath
          console.log fileEntry.fullPath + ' move to ' + cardEntry.fullPath
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
      window.resolveLocalFileSystemURI self.card.get('audio_url'), (fileEntry)->
        fileEntry.moveTo audioEntry, fileEntry.name, (entry) ->
          self.card.set 'audio_url', entry.fullPath
          #          self.audio_file_entry = entry
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
    temp_card_id = @card.id
    self = this
    cardDao = new app.dao.CardDAO(app.db)
    cardDao.create @model.id, @card.get('image_url'), @card.get('audio_url'), @card.get('message'), (data)->
      console?.log 'save to local database successfully.'
      self.card.id = data.id
      cardDao.deleteById temp_card_id, ->
        console?.log 'delete card[' + self.card.id + '] from local database successfully.'
        self.upload()

  upload: ->
    console.log 'upload init'
    @uploadCard = new app.models.Card()
    @uploadCard.set 'client_id', @card.id
    @uploadCard.on 'change:uploadFinish', @uploadFinish, this
    self = this
    window.resolveLocalFileSystemURI @card.get('image_url'), (imageFileEntry)->
      console.log imageFileEntry.fullPath
      if self.card.get('audio_url')
        window.resolveLocalFileSystemURI self.card.get('audio_url'), (audioFileEntry)->
          console.log audioFileEntry.fullPath
          self.uploadCard.uploadFile imageFileEntry, audioFileEntry
        , ->
          console?.log 'resolveLocalFileSystemURI failed:' + self.card.get('audio_url')
      else
        self.uploadCard.uploadFile imageFileEntry, null
    , ->
      console?.log 'resolveLocalFileSystemURI failed:' + self.card.get('image_url')

  uploadFinish: ->
    switch @uploadCard.get('uploadFinish')
      when 1
        @finish = @finish + 1
        @$('.measure').text @finish + '/' + @unsyncSize
        @card.set 'synchronized', 1
        @unsyncs = _.without(@unsyncs, @card)
        console.log 'upload finish -> synchronize count:' + _.size(@unsyncs)
        if _.size(@unsyncs) is 0
          $('.ui-loader').hide()
          app.utils.toast.showShort '同步完成'
        else
          @card = _.first(@unsyncs)
          @localSynchronize()
      when -1
        $('.ui-loader').hide()
        app.utils.toast.showShort '认证失败，请重新登录'
        window.localStorage.setItem 'sign_in_callback', window.location.hash.replace('#', '')
        window.location.hash = 'sign_in'
      when -2
        $('.ui-loader').hide()
        app.utils.toast.showLong '连接服务器失败，请稍候再试'
      else