# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

base = '/ext/jquery/ztree/ztree-master'
version = '3.5'

module.exports = roaster.dependency(
  ztree: "https://codeload.github.com/zTree/zTree_v#{version[0]}/zip/master|jquery/ztree"
  "#{base}/js/jquery.ztree.all-#{version}.js"
  "#{base}/js/jquery.ztree.exhide-#{version}.js"
  "#{base}/css/zTreeStyle/zTreeStyle.css"
)
