gwt = global.gwt # set by uSDLC2/scripts/gwt

# Module requirements
internet = require('internet')(); processes = require('processes')
path = require('path'); os = require('system'); fs = require('file-system')

# Common variable across instrumentation
file_name = ''
temp_directory = ''
file_path = -> path.join temp_directory, file_name

gwt.rules( # Rules used by child pages
  /An? (.+) operating system/, (system) ->
    @skip.section("not running on #{system}") if not os.expecting(system)
    @next()

  /Internet access/, ->
    internet.available (error) =>
      @skip.section("Internet not available") if error
      @next()

  /working with a file called '(.*)'/, (all, name) ->
    file_name = name
    @next()

  /in a temporary directory ending in '(.*)'/, (ending) ->
    console.log temp_directory = path.join os.tmpDir(), ending
    fs.mkdir temp_directory, @next

  /download from github project '(.*)' at '(.*)'/, (project, at) ->
    @maximum_step_time = 120
    internet.download.to(file_path()).
      from "https://raw.github.com/#{project}/#{at}/#{file_name}", @next

  /file exists/, ->
    fs.exists file_path(), (exists) =>
      @next(@error "#{file_path()} expected, but does not exist" if not exists)

  /run '(.*)'/, (command_line) ->
    fs.in_directory temp_directory, =>
      processes().cmd command_line, @next
      
  /if the file does not exist/, ->
    fs.exists file_path(), (exists) =>
      @skip.statements() if exists
      @next()

  /and confirm a file '(.*)' now exists/, (name) ->
    fs.exists path.join(temp_directory, name), (exists) =>
      throw "#{name} expected to exist" if not exists
      @next()

  /download from github project '(.*)'/, (project) ->
    projectName = project.split('/').pop()
    temp_directory = path.join os.tmpDir(), projectName
    fs.mkdir temp_directory, =>
      old_file_name = file_name
      file_name = 'install-usdlc-on-unix.sh'
      at = 'master/release'
      internet.download.to(file_path()).
      from "https://raw.github.com/#{project}/#{at}/#{file_name}", =>
        instrument.in_directory temp_directory, =>
          processes().cmd file_path(), '.', 'no-go', =>
            file_name = old_file_name
            @next()
)