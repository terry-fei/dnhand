colors = require('colors')

console.log('bold'.bold)
console.log('italic'.italic)
console.log('underline'.underline)
console.log('inverse'.inverse)
console.log('yellow'.yellow)
console.log('cyan'.cyan)
console.log('white'.white)
console.log('magenta'.magenta)
console.log('green'.green)
console.log('red'.red)
console.log('grey'.grey)
console.log('blue'.blue)
console.log('rainbow'.rainbow)
console.log('zebra'.zebra)
console.log('random'.random)
class ImageText
  constructor: (title, description, picurl, url) ->
    @title = title
    @description = description
    @picurl = picurl
    @url = url

it = new ImageText('hi', 'i am feit')
console.log it