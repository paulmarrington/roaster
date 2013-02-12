# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'common/step'

module.exports = (exchange) ->
  exchange.respond.client step, ->
    (step) ->
      step ::=
        # wrapper for dependencies that have asynchronous actions during
        # initialisation. Only for client. Contents need to be
        # module.exports = (error, next) -> init code
        # can include non-asynchronous that return anything, but they
        # must not return a function with two parameters or it will be
        # run.
        depends: (...urls) ->
          # after load we call the result with a next action parameter
          @parallels-setup()
          for url in urls => depends url, @parallel()
        # wrapper for library JS files that do not work on the global
        # name-space specifically. It is the same as  <script> tag.
        library: (...urls) ->
          # after load we call the result with a next action parameter
          @parallels-setup()
          for url in urls => depends.script-loader url, @parallel()

        # load static data asynchronously
        data: (...urls) ->
          for url in urls then depends.data-loader url, @parallel()
