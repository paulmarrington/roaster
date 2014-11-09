# Copyright (C) 2014 paul@marrington.net, see /GPL license

url = "http://dhtmlx.com/x/download/regular/download.php?"+
      "pack=dhtmlxScheduler_mobile.zip"
base = "/ext/dhtmlxScheduler_mobile/codebase"
require.dependency(
  dhtmlxScheduler_mobile: "#{url}|dhtmlxScheduler_mobile"
  "#{base}/dhxscheduler_mobile.js"
  "#{base}/dhxscheduler_mobile.css"
)
