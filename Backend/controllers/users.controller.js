const _ = require('lodash')
const request = require('request');
const config = require('../config')
const UserModel = require('../models/user.model')

module.exports = {
    async me(req, res) {
        const user = await UserModel.findById({ _id: req.user._id }).select('-password')
        res.send(user)
    },

    async loginSocial(req, res) {
        const userInfo = await this.verifyFacebookToken(req.body.token);
        if (userInfo) res.send(userInfo);
        else res.status(400).send({message: 'invalid token'});
    },

    async facebookCodeToToken(req, res) {
        const response = await new Promise((resolve, reject) => {
            request.get(
                `https://graph.facebook.com/v2.2/oauth/access_token?client_id=${config.fbID}&redirect_uri=https://eyo-dev.onrender.com/api/user/facebook/code&client_secret=${config.fbSecret}&code=${req.query.code}`, 
                (error, result, body) => {
                    resolve(JSON.parse(body));
                }
            );
        });
        console.log(typeof response, response)
        if (response && response.access_token) {
            const user = await verifyFacebookToken(response.access_token);
            const userObj = JSON.stringify(user.toObject());
            res.send(`
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta http-equiv="X-UA-Compatible" content="ie=edge">
                    <title>Document</title>
                </head>
                <body>
                    <p>Successfully logged in, finishing up...</p>
                    <script>
                        try {
                            Print.postMessage('${userObj}');
                        } catch (error) {
                            console.log('${userObj}');
                        }
                    </script>
                </body>
                </html>
            `);
        } else res.status(500).send('Error 1290');
    },

    async verifyToken(req, res) {
        const token = req.body.token;
        const userInfo = await verifyFacebookToken(token);
        if (userInfo) res.send(userInfo);
        else res.status(400).send({message: 'invalid token'});
    },
}

async function verifyFacebookToken(token) {
    const fbUser = await new Promise((resolve, reject) => {
        request.get(
            `https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}`,
            (error, res, body) => {
                // console.log({error, res, body})
                if (!error && res.statusCode == 200) resolve(JSON.parse(res.body));
                else reject(res);
            }
        );
    });
    if (fbUser) {
        fbUser.email = decodeURI(fbUser.email);
        return await UserModel.findOneAndUpdate({email: fbUser.email}, {
            ...fbUser,
            'authToken.token': token,
            authProvider: 'AuthProvider.Facebook'
        }, {upsert: true, new: true}).exec();
    }
    return false;
}
