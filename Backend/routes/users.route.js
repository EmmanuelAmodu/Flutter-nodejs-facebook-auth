const router = require('express').Router();
const usersController = require('../controllers/users.controller')
const asyncHandler = require('../middlewares/asyncHandler')

router.post('/login/social', asyncHandler(usersController.loginSocial, usersController))

router.get('/facebook/code', asyncHandler(usersController.facebookCodeToToken, usersController))

router.post('/validate/token', asyncHandler(usersController.verifyToken, usersController))

module.exports = router;
