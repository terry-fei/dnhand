
modules.exports = (grunt) ->


  grunt.initConfig {

    pkg: grunt.file.readJSON 'package.json'

    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*.coffee']
  }

  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.registerTask 'test', ['mochaTest']
