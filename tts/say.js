const say = require('say')

word = process.argv

// console.log(word)
say.speak(word.slice(2))
