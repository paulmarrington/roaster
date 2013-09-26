
###
# Basic logger, wrapping console.log and console.error.
# For now, we're just appending timestamps to the stdout and stderr output.
#
# Usage example:
#   logger = require 'common/logger'
#
#   logger.log 'My value'
#   # returns "29 July 2013 12:51:36 pm AEST My value"
#   logger.log 'My value', true
#   # returns in UTC format: "Mon, 29 Jul 2013 02:53:19 GMT My value"
###

logger =
  log: (value, utc) ->
    if utc
      console.log new Date().toUTCString(), value
    else
      console.log new Date().toLocaleString(), value
  
  error: (value, utc) ->
    if utc
      console.error new Date().toUTCString(), value
    else
      console.error new Date().toLocaleString(), value
    
module.exports = logger
