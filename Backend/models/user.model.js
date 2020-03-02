const _ = require('lodash')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const config = require('../config')
const KeysModel = require('../models/key.model')
const encrypt = require('../utils/encrypt')

const userSchema = new Schema({
    name: {
        type: String,
        required: true,
        minlength: 5,
        maxlength: 255
    },
    first_name: {
        type: String,
        required: true,
        minlength: 5,
        maxlength: 255
    },
    last_name: {
        type: String,
        required: true,
        minlength: 5,
        maxlength: 255
    },
    email: {
        type: String,
        unique: true,
        required: true,
        minlength: 5,
        maxlength: 255
    },
    authProvider: {
        type: String,
        required: true,
        enum: ['AuthProvider.Facebook', 'AuthProvider.Password']
    },
    authToken: {
        token: {
            type: String,
            required: function () {
                return this.authProvider !== 'AuthProvider.Password'
            }
        },
        secret: {
            type: String
        }
    },
    isEmailVerified: {
        type: Boolean,
        default: false
    },
    password: {
        type: String,
        required: function () {
            return this.authProvider === 'AuthProvider.Password'
        },
        minlength: 5,
        maxlength: 255
    },
});

userSchema.methods = {
    async generateAuthToken(exp) {
        const user = _.pick(this, ['_id', 'role'])
        const token = jwt.sign(user, config.appKey, { expiresIn: exp ? exp : '14d' })
        const encObj = encrypt.encrypt(token)
        await KeysModel.create(encObj)
        return encObj
    }
}

userSchema.statics = {
    getRoles() {
        return roles
    },

    async _generateHash(next) {
        const salt = await bcrypt.genSalt(10)
        this.password = await bcrypt.hash(this.password, salt)
        next();
    }
}

userSchema.pre('save', userSchema.statics._generateHash)
module.exports = mongoose.model('Users', userSchema)
