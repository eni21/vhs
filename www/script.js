

var video = document.getElementById('video')
var play = document.getElementById('play')
var pause = document.getElementById('pause')
var backward = document.getElementById('backward')
var forward = document.getElementById('forward')
var levels = document.getElementById('levels')
var videoSrc = 'http://127.0.0.1:8000/hls/aaa.m3u8'
if (Hls.isSupported()) {
    console.log("HLS supported")

    function updateLevels(hls) {
        levels.innerHTML = ''
        hls.levels.forEach((item, index) => {
            var level = document.createElement('div')
            level.classList.add('level')
            if (hls.currentLevel === item.level) level.classList.add('level__active')
            level.setAttribute('lev', index)
            level.innerHTML = `${item.height}p`
            level.onclick = function (e) { hls.currentLevel = +e.target.attributes.lev.value }
            levels.appendChild(level)
        })
    }

    function handleLevelError(hls, data) {
        hls.currentLevel = 0
        hls.currentLevel = -1
        hls.play()
    }

    var hls = new Hls({debug: true})
    hls.startLevel = 1
    console.log(hls)
    hls.loadSource(videoSrc)
    hls.attachMedia(video)

    hls.on(Hls.Events.MEDIA_ATTACHED, function() {
        video.muted = true
        video.play()
    })

    hls.on(Hls.Events.MANIFEST_PARSED, function (eventName, data) {
        console.log('manifestParsed')
        updateLevels(hls)
    })
    hls.on(Hls.Events.LEVEL_SWITCHING, function (eventName, data) {
        console.log('levelSwitching')
        updateLevels(hls)
    })
    hls.on(Hls.Events.LEVEL_SWITCHED, function (eventName, data) {
        console.log('levelSwitched')
        updateLevels(hls)
    })
    hls.on(Hls.Events.FRAG_BUFFERED, function (eventName, data) {
        console.log('fragBuffered')
        updateLevels(hls)
    })
    hls.on(Hls.Events.FRAG_CHANGED, function (eventName, data) {
        console.log('fragChanged')
        updateLevels(hls)
    })

    hls.on(Hls.Events.ERROR, function (eventName, data) {
        switch (data.details) {
            case Hls.ErrorDetails.LEVEL_EMPTY_ERROR:
                handleLevelError(hls, data)
                break
            case Hls.ErrorDetails.LEVEL_LOAD_ERROR:
                handleLevelError(hls, data)
                break
            case Hls.ErrorDetails.LEVEL_LOAD_TIMEOUT:
                handleLevelError(hls, data)
                break
        }
    })

} else if (video.canPlayType('application/vnd.apple.mpegurl')) {
    console.log("HLS not supported")
    video.src = videoSrc
}