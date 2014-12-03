module.exports = (grunt) ->
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'
    mochaTest:
      test:
        options:
          reporter: 'spec'
          timeout: 20000
          require: 'coffee-script/register'
        src: ['test/**/*.now.coffee']
  }

  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.registerTask 'test', ['mochaTest']
