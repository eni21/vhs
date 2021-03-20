var express = require('express')
var bodyParser = require('body-parser')
var app = express()

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
    extended: true
}))

app.use((req, res, next) => {
    var oldWrite = res.write,
      oldEnd = res.end;

    var chunks = []

    res.write = function (chunk) {
        chunks.push(chunk)
        return oldWrite.apply(res, arguments)
    }

    res.end = function (chunk) {
        if (chunk) chunks.push(chunk)
        var body = Buffer.concat(chunks).toString('utf8')
        console.log('res', req.path, `'${body}'`)
        oldEnd.apply(res, arguments)
    }
    console.log('req', req.method, req.path, req.query, req.body)
    next()
})


app.get('/', (req, res) => {
  res.send('hello world')
})

app.post('/connect', (req, res) => {
    res.status(200).send('ok')
})

app.post('/update', (req, res) => {
    res.status(200).send('err')
})

app.post('/publish', (req, res) => {
    switch (req.body.app) {
        case 'src':
            var rule = [
                { name: 'aaa', addr: '127.0.0.1' },
                { name: 'bbb', addr: '172.28.0.1' }
            ].find((item) => item.name === req.body.name)
            if (rule && req.body.addr === rule.addr) {
                res.status(200).send('ok')
            } else {
                res.status(400).send('wrong addr')
            }
            break
        case 'hls':
            if (req.body.addr === '127.0.0.1') {
                res.status(200).send('ok')
            } else {
                res.status(400).send('invalid addr')
            }
            break
        default:
            res.status(400).send(`unknown app ${req.body.app}`)
            break
    }
})

app.post('/play', (req, res) => {
    switch (req.body.app) {
        case 'src':
            if (req.body.addr === '127.0.0.1') {
                res.status(200).send('ok')
            } else {
                res.status(400).send('invalid addr')
            }
            break
        case 'hls':
            res.status(400).send('play disabled')
            break
        default:
            res.status(400).send('unknown app')
            break
    }
})

app.listen(3000, () => {
    console.log('Listening at http://127.0.0.1:3000...')
})
