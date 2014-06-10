module.exports =

  set: (response, name, value) ->
    response.setHeader "Set-Cookie", name+'='+value

  get: (request, name) ->
    cookies = request.headers.cookie
    res = (new RegExp("(^|;)\\s*#{name}=(.*?)(;|$)")).exec cookies
    return if res then res[2] else ''