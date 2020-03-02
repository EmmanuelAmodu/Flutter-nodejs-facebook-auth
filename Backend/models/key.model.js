const _ = require('lodash')
const mongoose = require('mongoose')
const Schema = mongoose.Schema

const keySchema = new Schema({
    iv: {
        type: String,
        required: true
    },
    encryptedData: {
        type: String,
        required: true
    },
    key: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('Keys', keySchema)
