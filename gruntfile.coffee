module.exports = (grunt) ->

  # grunt --production

  # TODO: appStylusFiles to clientStylusFiles or stylusFiles?

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
    # pkg: grunt.file.readJSON('package.json'),
    # use grunt templates for version tag? hmm

    # clean:
    #   client:
    #     src: ['client/**/*.css', 'client/**/*.js']

    jshint:
      gruntEsteClosure:
        # http://www.jshint.com/docs
        options:
          # we need it for closureTests
          evil: true
        src: [
          'node_modules/grunt-este-closure/tasks/**/*.js'
        ]

    stylus:
      app:
        options:
          'include css': true
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
          output_file: appDepsPath
          prefix: appDepsPrefix
          root: appDirs

    closureBuilder:
      options:
        closureBuilderPath: 'bower_components/closure-library/closure/bin/build/closurebuilder.py'
      app:
        options:
          root: appDirs
          namespace: 'app.start'
          output_file: appCompiledOutputPath
          output_mode: 'compiled'
          depsPath: appDepsPath
          compiler_jar: 'bower_components/closure-compiler/compiler.jar'
          compiler_flags: [
            '--output_wrapper="(function(){%output%})();"'
            '--compilation_level="ADVANCED_OPTIMIZATIONS"'
            '--warning_level="VERBOSE"'
          ]

    closureUnitTests:
      options:
        basePath: 'bower_components/closure-library/closure/goog/base.js'
        depsPath: appDepsPath
        prefix: appDepsPrefix
      app:
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
    watch:
      stylus:
        files: appStylusFiles
        tasks: 'stylus'

      js:
        files: appJsFiles.concat [
          '!' + appDepsPath
          '!' + appCompiledOutputPath
        ]
        tasks: if grunt.option 'production' then [
          'closureDeps'
          'closureUnitTests'
          'closureBuilder'
        ]
        else [
          'closureDeps'
          'closureUnitTests'
        ]

      coffee:
        files: appCoffeeFiles
        tasks: 'closureCoffee'

      closureTemplates:
        files: appTemplates
        tasks: 'closureTemplates'

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este-closure'

  if grunt.option 'production'
    grunt.registerTask 'default', [
      'stylus'
      'closureCoffee'
      'closureTemplates'
      'closureDeps'
      'closureUnitTests'
      'closureBuilder'
      'watch'
    ]
  else
    grunt.registerTask 'default', [
      'stylus'
      'closureCoffee'
      'closureTemplates'
      'closureDeps'
      'closureUnitTests'
      'watch'
    ]