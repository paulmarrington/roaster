module.exports =

  set: (response, cookies) ->
    response.setHeader "Set-Cookie", k+'='+v for k, v of cookies

  get: (request, name) ->
    cookies = request.headers.cookie
    res = (new RegExp("(^|;)\\s*#{name}=(.*?)(;|$)")).exec cookies
    return if res then res[2] else ''