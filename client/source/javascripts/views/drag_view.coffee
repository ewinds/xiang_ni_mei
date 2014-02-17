app.views.DragView = (puppet) ->
  @puppet = puppet[0]
  @drag = []
  @lastDrag = {}
  @WatchDrag = ->
    return  unless @drag.length
    d = 0

    while d < @drag.length
      left = $(@drag[d].el).offset().left
      top = $(@drag[d].el).offset().top
      x_offset = -(@lastDrag.pos.pageX - @drag[d].pos.pageX)
      y_offset = -(@lastDrag.pos.pageY - @drag[d].pos.pageY)
      left = left + x_offset
      top = top + y_offset
      @lastDrag = @drag[d]
      @drag[d].el.style.left = left + "px"
      @drag[d].el.style.top = top + "px"
      d++

  @OnDragStart = (event) ->
    touches = if event.gesture then event.gesture.touches else [event.originalEvent]
    t = 0

    while t < touches.length
      @lastDrag =
        el: @puppet
        pos: touches[t]
      return
      t++

  @OnDrag = (event) ->
    @drag = []
    touches = if event.gesture then event.gesture.touches else [event.originalEvent]
    t = 0

    while t < touches.length
      @drag.push
        el: @puppet
        pos: touches[t]
      t++

  @OnDragEnd = (event) ->
    @drag = []
    touches = if event.gesture then event.gesture.touches else [event.originalEvent]
    t = 0

    while t < touches.length
      t++

  this