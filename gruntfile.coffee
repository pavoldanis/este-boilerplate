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

  ###

  appDirs = [
    'bower_components/closure-library'
    'bower_components/closure-templates'
    'bower_components/este'
    'client/app/js'
  ]

  appStylusFiles = [
    'bower_components/este/**/*.styl'
    'client/**/*.styl'
  ]

  appCoffeeFiles = [
    'bower_components/este/**/*.coffee'
    'client/**/*.coffee'
  ]

  appJsFiles = [
    'bower_components/este/**/*.js'
    'client/**/*.js'
  ]

  appTemplates = [
    'bower_components/este/**/*.soy'
    'client/**/*.soy'
  ]

  appDepsPath = 'client/app/js/deps.js'

  appCompiledOutputPath = 'client/app/js/app.js'

  # from closure base.js dir to app root dir
  appDepsPrefix = '../../../../../'

  grunt.initConfig
    # pkg: grunt.file.readJSON('package.json')

    # clean:
    #   client:
    #     src: ['client/**/*.css', 'client/**/*.js']

    # jshint:
    #   gruntEsteClosure:
    #     # http://www.jshint.com/docs
    #     options:
    #       # we need it for closureTests
    #       evil: true
    #     src: [
    #       'node_modules/grunt-este-closure/tasks/**/*.js'
    #     ]

    stylus:
      options:
        'include css': true
      app:
        files: [
          expand: true
          src: appStylusFiles
          ext: '.css'
        ]

    # coffee:
    #   options:
    #     bare: false
    #   app:
    #     files: [
    #       expand: true
    #       src: appCoffeeFiles
    #       ext: '.js'
    #     ]

    closureCoffee:
      options:
        bare: true
      app:
        files: [
          expand: true
          src: appCoffeeFiles
          ext: '.js'
        ]

    closureTemplates:
      options:
        soyToJsJarPath: 'bower_components/closure-templates/SoyToJsSrcCompiler.jar'
      app:
        src: appTemplates

    closureDeps:
      options:
        depsWriterPath: 'bower_components/closure-library/closure/bin/build/depswriter.py'
      app:
        options:
          # TODO: consider make it global per projects
          output_file: appDepsPath
          prefix: appDepsPrefix
          root: appDirs

    closureBuilder:
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

    closureUnitTests:
      options:
        basePath: 'bower_components/closure-library/closure/goog/base.js'
      app:
        options:
          depsPath: appDepsPath
          prefix: appDepsPrefix
        src: [
          'bower_components/este/**/*_test.js'
          'client/**/*_test.js'
        ]

    connect:
      server:
        options:
          port: 8000
          keepalive: true

    # not ideal, but https://github.com/gruntjs/grunt/issues/581#issuecomment-12615946
    # wait for update or rewrite it for multiple tasks etc.
    watch:
      stylus:
        files: appStylusFiles
        tasks: 'stylus:app'

      js:
        files: appJsFiles.concat [
          '!' + appDepsPath
          '!' + appCompiledOutputPath
        ]
        tasks: if grunt.option('stage') then [
          'closureDeps:app'
          'closureUnitTests:app'
          'closureBuilder:app'
        ]
        else [
          'closureDeps:app'
          'closureUnitTests:app'
        ]

      coffee:
        files: appCoffeeFiles
        tasks: 'closureCoffee:app'

      closureTemplates:
        files: appTemplates
        tasks: 'closureTemplates:app'

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este-closure'

  grunt.registerTask 'run', 'To start development.', (app) ->
    tasks = [
      "stylus:#{app}"
      "closureCoffee:#{app}"
      "closureTemplates:#{app}"
      "closureDeps:#{app}"
      "closureUnitTests:#{app}"
    ]
    tasks.push "closureBuilder:#{app}" if grunt.option 'stage'
    tasks.push 'watch'
    grunt.task.run tasks

  grunt.registerTask 'default', 'run:app'