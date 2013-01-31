module.exports = (error, next) -> 
  async = -> next null, 'dep-async-1 result'
  setTimeout async, 300