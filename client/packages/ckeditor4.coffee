# Copyright (C) 2013-4 paul@marrington.net, see /GPL for license
version = "4.3.2"
pkg = "full"
base = "http://download.cksource.com/CKEditor/"+
  "CKEditor/CKEditor "
ckurl = "http://download.ckeditor.com"
plugin_dir = "ckeditor/plugins/"
pkgs =
  ckeditor4: "#{base}#{version}/"+
    "ckeditor_#{version}_#{pkg}.zip|."
  tableresize: "#{ckurl}/tableresize/releases/"+
    "tableresize_#{version}.zip|#{plugin_dir}"
  placeholder: "#{ckurl}/placeholder/releases/"+
    "placeholder_#{version}.zip|#{plugin_dir}"
  widget: "#{ckurl}/widget/releases/"+
    "widget_#{version}.zip|#{plugin_dir}"
  lineutils: "#{ckurl}/lineutils/releases/"+
    "lineutils_#{version}.zip|#{plugin_dir}"
  find: "#{ckurl}/find/releases/"+
    "find_#{version}.zip|#{plugin_dir}"

module.exports = (loaded) ->
  require.dependency pkgs, '/ext/ckeditor/ckeditor.js', loaded