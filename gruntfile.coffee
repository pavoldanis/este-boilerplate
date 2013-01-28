module.exports = (grunt) ->

  closureNamespaces = [
    'bower_components/closure-library'
    'bower_components/closure-templates'
    'bower_components/este'
    'client/app/js'
  ]

  closureCoffeeApp = [
    'bower_components/este/**/*.coffee'
    'client/**/*.coffee'
  ]

  depsPath = 'client/app/js/deps.js'
  # from closure base.js to root, other paths are derived
  depsPrefix = '../../../../../'

  grunt.initConfig
    # pkg: grunt.file.readJSON('package.json'),
    # use grunt templates for version tag? hmm

    # clean:
    #   client:
    #     src: ['client/**/*.css', 'client/**/*.js']

    # http://www.jshint.com/docs/
    jshint:
      client:
        options:
          # we need it for closureTests
          evil: true
        src: [
          'client/app/**/*.js'
          '!client/app/app.js'
          'node_modules/grunt-este-closure/tasks/**/*.js'
        ]

    stylus:
      app:
        options:
          'include css': true
        files: [
          expand: true
          src: [
            'bower_components/este/**/*.styl'
            'client/**/*.styl'
          ]
          ext: '.css'
        ]

    # coffee:
    #   options:
    #     bare: false
    #   app:
    #     files: [
    #       expand: true
    #       src: [
    #         'bower_components/este/**/*.coffee'
    #         'client/**/*.coffee'
    #       ]
    #       ext: '.js'
    #     ]

    closureCoffee:
      options:
        bare: true
      app:
        files: [
          expand: true
          src: closureCoffeeApp
          ext: '.js'
        ]

    closureTemplates:
      options:
        soyToJsJarPath: 'bower_components/closure-templates/SoyToJsSrcCompiler.jar'
      app:
        src: [
          'bower_components/este/**/*.soy'
          'client/**/*.soy'
        ]

    closureDeps:
      options:
        depsWriterPath: 'bower_components/closure-library/closure/bin/build/depswriter.py'
      app:
        options:
          output_file: depsPath
          prefix: depsPrefix
          root: closureNamespaces

    closureBuilder:
      options:
        closureBuilderPath: 'bower_components/closure-library/closure/bin/build/closurebuilder.py'
      app:
        options:
          root: closureNamespaces
          namespace: 'app.start'
          output_file: 'client/app/app.js'
          output_mode: 'compiled'
          compiler_jar: 'bower_components/closure-compiler/compiler.jar'
          compiler_flags: [
            '--output_wrapper="(function(){%output%})();"'
            '--js="client/app/js/deps.js"'
            '--compilation_level="ADVANCED_OPTIMIZATIONS"'
            '--warning_level="VERBOSE"'
          ]

    closureUnitTests:
      options:
        basePath: 'bower_components/closure-library/closure/goog/base.js'
        depsPath: depsPath
        prefix: depsPrefix
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

    # TODO: write better watch, update just changed file
    #       consider own watch task from old este
    watch:
      stylus:
        files: 'client/**/*.styl'
        tasks: 'stylus'

      js:
        files: [
          'client/**/*.js'
          '!client/app/js/deps.js'
          '!client/app/app.js'
        ]
        tasks: [
          'jshint'
          'closureDeps'
          'closureUnitTests'
          # add as grunt fok:production or something else
          # 'closureBuilder'
        ]

      coffee:
        files: closureCoffeeApp
        tasks: 'closureCoffee'

      closureTemplates:
        files: [
          'bower_components/este/**/*.soy'
          'client/**/*.soy'
        ]
        tasks: 'closureTemplates'

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este-closure'

  grunt.registerTask 'default', [
    # 'clean', deletes _test
    'jshint'
    'stylus'
    'closureCoffee'
    'closureTemplates'
    'closureDeps'
    # todo: add builder as cmd options
    'watch',
  ]