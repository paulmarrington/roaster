# Copyright (C) 2014 paul@marrington.net, see /GPL license

url = "http://dhtmlx.com/x/download/regular/download.php?"+
      "pack=dhtmlxScheduler.zip"
module.exports = (loaded) -> require.dependency(
  dhtmlxScheduler: "#{url}|dhtmlxScheduler"
  "/ext/dhtmlxScheduler/codebase/dhtmlxscheduler.js"
  "/ext/dhtmlxScheduler/codebase/dhtmlxscheduler.css"
  loaded
)
