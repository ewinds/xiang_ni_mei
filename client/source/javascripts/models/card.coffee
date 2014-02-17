class app.models.Card extends Backbone.Model
  url: app.baseUrl + 'api/cards.json'

  defaults:
    uploadFinish: 0

  uploadFile: (imageEntry, audioEntry)->
    console.log 'Card::uploadFile init'
    console.log imageEntry
    console.log audioEntry
    self = this
    @readFile imageEntry, 'image_data', ->
      if audioEntry?
        self.readFile audioEntry, 'audio_data', $.proxy(self.saveRemote, self)
      else
        self.saveRemote()
  readFile: (fileEntry, item, callback)->
    self = this
    fileEntry.file (file)->
      reader = new FileReader()
      reader.onload = ((theFile, that) ->
        (e) ->

          #set model
          that.set item, e.target.result
          callback()

      )(file, self)
      reader.readAsDataURL(file)
    , ->
      console?.log 'got file failed:' + fileEntry.fullPath

  saveRemote: ->
    self = this
    @save @attributes,
      success: (data)->
        cardDAO = new app.dao.CardDAO(app.db)
        cardDAO.synchronized self.get('client_id'), ->
          self.set 'uploadFinish', 1
      error: (model, response)->
        if response.status is 401
          self.set 'uploadFinish', -1
        else
          self.set 'uploadFinish', -2
