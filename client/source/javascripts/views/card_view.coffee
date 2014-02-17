class app.views.CardView extends Backbone.View
  events:
    "tap #back-button": "back"
    "tap #microphone-button": "play"

  render: ->
    @$el.html @template(@model.toJSON())
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  play: (event)->
    event.preventDefault()
    url = decodeURIComponent(@model.get('audio_url'))
    console?.log 'prepare to play:' + url
    my_media = new Media(url, ->
      console?.log "playAudio():Audio Success"
    , (err) ->
      console?.log "playAudio():Audio Error: " + err
    )

    # Play audio
    my_media.play()
