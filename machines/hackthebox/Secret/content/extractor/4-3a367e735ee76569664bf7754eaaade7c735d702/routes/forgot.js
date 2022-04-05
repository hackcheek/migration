const router = require('express').Router();
const verifytoken = require('./verifytoken')
const User = require('../model/user');

router.get('/priv', verifytoken, (req, res) => {
    // res.send(req.user)

    const userinfo = { name: req.user }

    const name = userinfo.name.name;

    if (name == 'theadmin') {
        res.json({
            role: {
                role: "you are admin",
                desc: "{path to the binary}"
            }
        })
    }
    else {
        res.json({
            role: {
                role: "not enough privilages",
                desc: userinfo.name.name
            }
        })
    }

})


module.exports = router