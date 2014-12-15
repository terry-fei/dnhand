var Then = require('thenjs')

function task(arg, callback) { // 模拟异步任务
  Then.nextTick(function () {
    callback(null, arg);
  });
}

Then.parallel([
  function (cont) {
    task(1, cont)
  },
  function (cont) {
    task(2, cont)
  },
  function (cont) {
    // task(3, cont)
    cont(new Error('occur err'))
  },
  function (cont) {
    task(4, cont)
  },
  function (cont) {
    task(5, cont)
  }
]).fin(function (cont, error, result) {
  console.log(error)
  console.log(result)
})
