const router = require('express').Router()
router.use('/user', require('./users.route'))
module.exports = router
