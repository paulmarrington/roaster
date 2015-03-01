# Copyright (C) 2014 paul@marrington.net, see /GPL license
roaster = require 'roaster'

module.exports = file =
  read: (file_name, read) ->
    require.data file_name, (err, contents) ->
      id = file_name.replace /[\.\/]/g, '_'
      originals[id] = contents ? ''
      read err, contents # pronounce as 'red'

  write: (file_name, content, written) ->
    patch = require 'common/patch.coffee'
    do file.save = (file_name, content, written) ->
      if not file_name or processing[file_name]
        return written()
      id = file_name.replace /[\.\/]/g, '_'
      processing[file_name] = true
      roaster.message 'Clear: Saved'
      original = originals[id] ? ''
      return written() if content is original
      saved = -> processing[file_name] = false; written(0, 1)
      save_url = "/server/http/save.coffee?name=#{file_name}"
      patch.create file_name, original, content, (changes) ->
        file.post save_url, changes, (err, data) ->
          if err
            roaster.message "Error: Save failed"
            if confirm('Save failed\n'+
            'Do you want to merge the changes?')
              file.merge file_name, id, content, written
            return saved()
          usdlc.originals[original_id] = content
          roaster.message 'Pass: Saved'
          saved()
        
  on_change: (id, save) ->
    clearTimeout(timer)
    roaster.message "Clear: Saved"
    save_actions[id] = save
    timer = setTimeout(@saver, 1000)
  saver: -> # does primary save last by reversing order
    a for a in (v for k,v of save_actions).reverse()
  
  post: (url, changes, posted) ->
    url += if /\?/.test(url) then '&' else '?'
    url += (new Date()).getTime()
    rq = new XMLHttpRequest()
    rq.addEventListener "load", ->  posted null, @responseText
    rq.addEventListener "error", -> posted @status ? 'error'
    rq.addEventListener "abort", -> posted @status ? 'abort'
    rq.open 'POST', url, true
    rq.send changes
    
  merge: (file_name, id, content, merged) ->
    merged('Merging under construction')

processing = {}; originals = {}; save_actions = {}
patch = null; timer = null