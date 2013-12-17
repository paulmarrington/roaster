# Copyright (C) 2013 paul@marrington.net, see /GPL for license

Date::format = (fmt = 'YYMMDD-HHmmSSsss') ->
  text = []
  fmt = fmt[0..]  # clone
  # so we can create one or 2 digits on demand
  double = (num) ->
    if fmt[1] is c
      num = "0#{num}" if num < 10
      fmt = fmt[1..]
    text.push "#{num}"

  while fmt.length
    switch c = fmt[0]
      when 'Y'
        if fmt[0..3] is 'YYYY'
          text.push "#{@getFullYear()}"
          fmt = fmt[3..]
        else if fmt[0..1] is 'YY'
          text.push "#{@getFullYear() % 100}"
          fmt = fmt[1..]
        else
          text.push "#{@getFullYear() % 10}#{c}"
      when 'M' then double @getMonth() + 1
      when 'D' then double @getDate()
      when 'H' then double @getHours()
      when 'm' then double @getMinutes()
      when 'S' then double @getSeconds()
      when 's'
        num = @getMilliseconds()
        if fmt[1] is c
          num = "0#{num}" if num < 100
          fmt = fmt[1..]
        if fmt[1] is c
          num = "0#{num}" if num < 10
          fmt = fmt[1..]
        text.push "#{num}"
      else
        text.push c
    fmt = fmt[1..]
  # combine result
  return text.join ''