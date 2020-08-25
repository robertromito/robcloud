const express = require('express')
const app = express()

const bodyParser = require('body-parser')
app.use(bodyParser.urlencoded())

app.post('/bot', (req, res) => {
    console.log(`Smoky been woken by ${req.body.username}`)
    res.send({
        "text": `Meow 🐈 I want treats from *${req.body.username}* 😽 Purr 😻`
    })
})

const server = app.listen(process.env.PORT || 3000, () => {
    console.log(
        'Smoky is up and ready to beg for treats [port: %d, mode: %s]',
        server.address().port,
        app.settings.env)
});