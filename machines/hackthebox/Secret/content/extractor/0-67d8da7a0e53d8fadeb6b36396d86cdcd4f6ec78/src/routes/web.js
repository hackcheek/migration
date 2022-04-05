const express = require('express')
const newsRouter = express.Router()
const axios = require('axios')

newsRouter.get('', async (req, res) => {
    res.render('home')
})

//helpus
newsRouter.get('/docs', async (req, res) => {
   res.render('doc')
})

newsRouter.use(function (req, res, next) {
    res.status(404).render('404');
});

module.exports = newsRouter
