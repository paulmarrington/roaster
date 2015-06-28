# Copyright (C) 2013 paul@marrington.net, see /GPL for license

Date::format = (fmt = 'YYYYMMDD-HHmmSS.sss') ->
  text = []; zone = ''; index = 0
  # so we can create one or 2 digits on demand
  double = (num) ->
    if fmt[index] is c
      num = "0#{num}" if num < 10
      index++
    text.push "#{num}"
    
  get = (field) => (@['get'+zone+field])()

  while index < fmt.length
    switch c = fmt[index++]
      when 'U' then zone = 'UTC'
      when 'Y'
        year = get('FullYear')
        if fmt[index..index+2] is 'YYY'
          text.push "#{year}"
          index += 3
        else if fmt[index] is 'Y'
          text.push "#{year % 100}"
          index++
        else
          text.push "#{year % 10}#{c}"
      when 'M' then double get('Month') + 1
      when 'D' then double get('Date')
      when 'H' then double get('Hours')
      when 'm' then double get('Minutes')
      when 'S' then double get('Seconds')
      when 's'
        num = get('Milliseconds')
        if fmt[index] is c
          num = "0#{num}" if num < 100
          index++
        if fmt[index] is c
          num = "0#{num}" if num < 10
          index++
        text.push "#{num}"
      else
        text.push c
  # combine result
  return text.join ''
