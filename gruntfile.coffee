module.exports = (grunt) ->

  ###
    Start simple static server in another cmd window.
      grunt connect

    Start development. Compile all and start watching.
      grunt run:app

    Compiles code with closureBuilder.
      grunt run:app --stage

    Debug makes compiled code readable.
      grunt run:app --stage=debug

    Default task runs grunt run:app.
      grunt
      grunt --stage
      grunt --stage=debug

  ###

  appDirs = [
    'bower_components/closure-library'
    'bower_components/closure-templates'
    'bower_components/este-library'
    'client/app/js'
  ]

  appStylusFiles = [
    'bower_components/este-library/**/*.styl'
    'client/app/css/**/*.styl'
  ]

  appCoffeeFiles = [
    'bower_components/este-library/**/*.coffee'
    'client/app/js/**/*.coffee'
  ]

  appJsFiles = [
    'bower_components/este-library/**/*.js'
    'client/app/js/**/*.js'
  ]

  appTemplates = [
    'bower_components/este-library/**/*.soy'
    'client/app/js/**/*.soy'
  ]

  appDepsPath =
    'client/app/assets/deps.js'

  appCompiledOutputPath =
    'client/app/assets/app.js'

  # from closure base.js dir to app root dir
  appDepsPrefix = '../../../../'

  grunt.initConfig
    # pkg: grunt.file.readJSON('package.json')

    # TODO:
    # clean:
    #   client:
    #     src: ['client/**/*.css', 'client/**/*.js']

    jshint:
      gruntEste:
        # http://www.jshint.com/docs
        options:
          # we need it for closureTests
          evil: true
        src: [
          'node_modules/grunt-este/tasks/**/*.js'
        ]

    # same params as grunt-contrib-stylus
    esteStylus:
      options:
        'include css': true
      app:
        files: [
          expand: true
          src: appStylusFiles
          ext: '.css'
        ]

    # same params as grunt-contrib-coffee
    esteCoffee:
      options:
        bare: true
      app:
        files: [
          expand: true
          src: appCoffeeFiles
          ext: '.js'
        ]

    esteTemplates:
      options:
        soyToJsJarPath: 'bower_components/closure-templates/SoyToJsSrcCompiler.jar'
      app:
        src: appTemplates

    esteDeps:
      options:
        depsWriterPath: 'bower_components/closure-library/closure/bin/build/depswriter.py'
      app:
        options:
          # TODO: consider make it global per projects
          output_file: appDepsPath
          prefix: appDepsPrefix
          root: appDirs
      este:
        options:
          output_file: 'bower_components/este-library/deps.js'
          prefix: '../../../../'
          root: [
            'bower_components/este-library'
            'bower_components/closure-library'
            'bower_components/closure-templates'
          ]

    esteBuilder:
      options:
        closureBuilderPath: 'bower_components/closure-library/closure/bin/build/closurebuilder.py'
        compiler_jar: 'bower_components/closure-compiler/compiler.jar'
        namespace: 'app.start'
        output_mode: 'compiled'
        compiler_flags: if grunt.option('stage') == 'debug' then [
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          '--define=goog.DEBUG=true'
          '--debug=true'
          '--formatting="PRETTY_PRINT"'
        ]
        else [
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          '--define=goog.DEBUG=false'
        ]
      app:
        options:
          root: appDirs
          output_file: appCompiledOutputPath
          depsPath: appDepsPath

    esteUnitTests:
      options:
        basePath: 'bower_components/closure-library/closure/goog/base.js'
      app:
        options:
          depsPath: appDepsPath
          prefix: appDepsPrefix
        src: [
          'bower_components/este-library/**/*_test.js'
          'client/**/*_test.js'
        ]

    connect:
      server:
        options:
          port: 8000
          keepalive: true

    esteWatch:
      app:
        styl:
          files: appStylusFiles
          tasks: 'esteStylus:app'

        js:
          files: appJsFiles
          tasks: if grunt.option('stage') then [
            'esteDeps:app'
            'esteUnitTests:app'
            'esteBuilder:app'
          ]
          else [
            'esteDeps:app'
            'esteUnitTests:app'
          ]

        coffee:
          files: appCoffeeFiles
          tasks: 'esteCoffee:app'

        soy:
          files: appTemplates
          tasks: 'esteTemplates:app'

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este'

  grunt.registerTask 'run', 'To start development.', (app) ->
    tasks = [
      "esteStylus:#{app}"
      "esteCoffee:#{app}"
      "esteTemplates:#{app}"
      "esteDeps:este"
      "esteDeps:#{app}"
      "esteUnitTests:#{app}"
    ]
    if grunt.option 'stage'
      tasks.push "esteBuilder:#{app}"
    tasks.push 'esteWatch'

    grunt.task.run tasks

  grunt.registerTask 'default', 'run:app'