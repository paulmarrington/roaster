require.json = (url, on_loaded) ->
  @data url, (error, text) ->
    return on_loaded(error) if error
    on_loaded null, JSON.parse text

require.css = (url) ->
  link = document.createElement("link")
  link.type = "text/css"
  link.rel = 'stylesheet'
  link.href = url
  document.getElementsByTagName("head")[0].appendChild(link)
  
require.data = (url, next) ->
  contents = []
  @stream url, pragma: "no-cache",
  (error, text, is_complete) ->
    contents.push text
    contents = [] if error
    next(error, contents.join('')) if is_complete
      
require.stream = (url, headers..., onData) ->
  url += '.script' if url.indexOf('.') is -1
  request = new XMLHttpRequest()
  previous_length = 0
  request.onreadystatechange = ->
    return if request.readyState <= 2
    try
      text = request.responseText.substring(previous_length)
      previous_length = request.responseText.length
    catch e then text = ''
    error = null
    if is_complete = (request.readyState is 4)
      if request.status isnt 200
        error = request.statusText
    onData(error, text, is_complete)
  request.open 'GET', url, true
  for header in headers
    request.setRequestHeader(k, v) for k, v of header
  request.send null
