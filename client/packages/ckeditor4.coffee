# Copyright (C) 2013-4 paul@marrington.net, see /GPL for license
version = "4.4.3"
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
  code_tag: "#{ckurl}/codetag/releases/codetag_0.1_0.zip"+
    "|#{plugin_dir}"
  google_web_fonts: "#{ckurl}/ckeditor-gwf-plugin/releases/"+
    "ckeditor-gwf-plugin_0.1.1.zip|#{plugin_dir}/"+
    "ckeditor-gwf-plugin"
  leaflet_maps: "#{ckurl}/leaflet/releases/leaflet_1.2.1.zip"+
    "|#{plugin_dir}"
  div: "#{ckurl}/div/releases/div_#{version}.zip|#{plugin_dir}"
  page_break: "#{ckurl}/pagebreak/releases/"+
    "pagebreak_#{version}.zip|#{plugin_dir}"
  code_snippet: "#{ckurl}/codesnippet/releases/"+
    "codesnippet_#{version}.zip|#{plugin_dir}"

module.exports = (loaded) ->
  require.dependency pkgs, '/ext/ckeditor/ckeditor.js', loaded