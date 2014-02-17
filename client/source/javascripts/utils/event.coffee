app.utils.event =
  handleTapLink: (e)->
    href = e.currentTarget.href
    return  if e.defaultPrevented or not href
    e.preventDefault()
    location.href = href