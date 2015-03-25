# Copyright (C) 2015 paul@marrington.net, see /GPL for license

class Mode
  constructor: ->
    if map = localStorage.CodeMirror_mode_map
      @map = JSON.parse(map)
    else
      @map = default_map
      
  from_filename: (name) ->
    while name?.length
      return { mode: ext, ext: name } if ext = @map[name]
      break if not (dot = name.indexOf('.'))
      name = name[dot+1..]
    return { mode:'text', ext: name }
  
  add: (more) ->
    @map[k] = v for k,v of more
  
default_map =
  apl: 'apl', as3: 'apl', asf: 'apl'
  c: 'clike', cpp: 'clike', h: 'clike', cs: 'clike'
  chh: 'clike', hh: 'clike', h__: 'clike', hpp: 'clike'
  hxx: 'clike', cc: 'clike', cxx: 'clike', c__: 'clike'
  'c++': 'clike', stl: 'clike', sma: 'clike'
  java: 'clike', scala: 'clike', clj: 'clojure'
  cpy: 'cobol', cbl: 'cobol',cob: 'cobol'
  coffee: 'coffeescript', coffeescript: 'coffeescript'
  'gwt.coffee': 'coffeescript'
  vlx: 'commonlisp', fas: 'commonlisp', lsp: 'commonlisp'
  el: 'commonlisp', css: 'css', less: 'css'
  dl: 'd', d: 'd', diff: 'diff', dtd: 'dtd', dylan: 'dylan'
  ecl: 'ecl', e: 'eiffel', erl: 'erlang', hrl: 'erlang'
  f: 'fortran', for: 'fortran', FOR: 'fortran'
  f95: 'fortran', f90: 'fortran', f03: 'fortran',
  gas: 'gas', gfm: 'gfm', feature: 'gherkin', go: 'go'
  groovy: 'groovy', "html.haml": 'haml', hx: 'haxe'
  lhs: 'haskell', gs: 'haskell', hs: 'haskell'
  asp: 'htmlembedded', jsp: 'htmlembedded',
  ejs: 'htmlembedded', http: 'http'
  html: 'htmlmixed', htm: 'htmlmixed', '.py.jade': 'jade'
  js: 'javascript', json: 'javascript', jinja2: 'jinja2'
  jl: 'julia', ls: 'livescript', lua: 'lua'
  markdown: 'markdown', mdown: 'markdown', mkdn: 'markdown'
  md: 'markdown', mkd: 'markdown', mdwn: 'markdown'
  mdtxt: 'markdown', mdtext: 'markdown'
  mdx: 'mirc', dcx: 'mirc'
  ml: 'mllike', fs: 'mllike', fsi: 'mllike'
  mli: 'mllike', fsx: 'mllike', fsscript: 'mllike'
  nginx: 'nginx', nt: 'ntriples', mex: 'octave'
  pas: 'pascal', pegjs: 'pegjs', ps: 'perl'
  php: 'php', 'lib.php': 'php'
  pig: 'pig', ini: 'properties', properties: 'properties'
  pp: 'puppet', py: 'python', q: 'q', r: 'r'
  rpm: 'rpm', 'src.rpm': 'rpm', rst: 'rst', rb: 'ruby'
  rs: 'rust', sass: 'sass', scm: 'scheme', ss: 'scheme'
  sh: 'shell', sieve: 'sieve'
  sm: 'smalltalk', st: 'smalltalk', tpl: 'smartymixed'
  solr: 'solr', sparql: 'sparql', sql: 'sql'
  stex: 'stex', tex: 'stex', tcl: 'tcl', tw: 'tiddlywiki'
  tiki: 'tiki', toml: 'toml', ttl: 'turtle', vb: 'vb'
  bas: 'vbscript', vbs: 'vbscript', vtl: 'velocity'
  v: 'verilog', xml: 'xml'
  xquery: 'xquery', xq: 'xquery', xqy: 'xquery'
  yaml: 'yaml', yml: 'yaml', z80: 'z80', asm: 'z80'
  
module.exports = Mode