# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
require! path; require! fs; require! dirs.mkdirs; require! step

# curl 'http://localhost:9009/release/new-project.ls?path=..&name=test&port=9020'
module.exports = (exchange) ->
  config = exchange.request.url.query
  config.error = false

  project-path = path.join config.path, config.name

  done = (msg) ->
    config.result = msg
    exchange.respond.json config
  failure = (msg) ->
    config.error = true
    done msg

  if not config.path or not config.name or not config.port
    failure 'path=.. name=MyProjectName port=9009'

  copy = (...files, next) ->
    copy-one = (error, files) ->
      return next(error) if error or files.length is 0
      file = files.pop()
      source = fs.node 'release', file
      target = path.join project-path, file
      fs.exists target, (exists) ->
        if not exists
          fs.copy source, target, (error) -> copy-one error, files
        else
          copy-one error, files
    copy-one(null, files.slice 0)

  make-project-dirs = (...dirs, next) ->
    make-one = (error, dirs) ->
      return next(error) if error or dirs.length is 0
      mkdirs path.join(project-path, dirs.pop()), (error) -> make-one error, dirs
    make-one null, dirs.slice 0

  step(
    ->
      @throw_errors = false
      make-project-dirs 'client', 'ext', 'boot', 'config', 'scratch', 'scripts', @
    (error) ->
      @(error) if error
      copy 'go', 'go.bat', 'index.html', 'app.ls', 'app.stylus',
           'boot/project-init.ls', 'config/base.ls', 'config/debug.ls',
           'config/production.ls', 'client/favicon.ico', @
    (error) ->
      @(error) if error
      fs.symlink fs.node(''), path.join(project-path, 'ext/uSDLC_Node_Server'), 'dir', @
    (error) ->
      # skip error as it just means destination exists
      @parallel(
        -> fs.chmod path.join(project-path, 'go'), 8~700, @
        -> fs.appendFile path.join(project-path, 'config/base.ls'),
            "  environment.port ?= #{config.port}\n", @
      )
    (error) ->
      return failure(error) if error
      done "Project '#{config.name}' created"
  )
