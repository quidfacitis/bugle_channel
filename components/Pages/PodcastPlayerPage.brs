sub init()
  m.top.id = "podcastPlayerPage"
  m.dummyLabel = m.top.findNode("dummyLabel")
  m.progressBarContainer = m.top.findNode("progressBarContainer")
  m.progressBar = m.top.findNode("progressBar")
  m.currentSpot = m.top.findNode("currentSpot")
  m.startTime = m.top.findNode("startTime")
  m.endTime = m.top.findNode("endTime")
  assignProgressBarTranslation()
  m.elapsedSeconds = 0
end sub


sub assignProgressBarTranslation()
  boundingRect = m.progressBarContainer.boundingRect()
  xTranslation = (1920 - boundingRect.width) / 2
  yTranslation = 800
  m.progressBarContainer.translation = [xTranslation, yTranslation]
  'assign initial translation of current spot marker
  m.currentSpot.translation = [(xTranslation + 120), (yTranslation - 15)]
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  m.dummyLabel.text = pageParams.episodeTitle

  if pageParams.episodeMetadata <> invalid
    createAudioNode(pageParams.episodeMetadata.enclosure)
    assignEndTime(pageParams.episodeMetadata["itunes:duration"])
    totalSeconds = convertDurationToSeconds(pageParams.episodeMetadata["itunes:duration"])
    m.pixelsPerSecond = getPixelsPerSecond(totalSeconds)
  end if
end sub

function convertDurationToSeconds(duration as string) as integer
  splitDuration = duration.split(":")
  return splitDuration[0].toInt() * 60 + splitDuration[1].toInt()
end function

function convertSecondsToDuration(seconds as integer) as string
  minutes = int(seconds / 60)
  secs = seconds mod 60

  if minutes = 0
    minutes = minutes.toStr() + "0"
  else if minutes.toStr().len() = 1
    minutes = "0" + minutes.toStr()
  else
    minutes = minutes.toStr()
  end if

  if secs = 0
    secs = secs.toStr() + "0"
  else
    secs = secs.toStr()
  end if

  return minutes + ":" + secs
end function

function getPixelsPerSecond(totalSeconds as integer) as float
  return m.progressBar.width / totalSeconds
end function


sub createAudioNode(podcastUrl as string)
  m.audio = createObject("roSGNode", "audio")
  audioContent = createObject("roSGNode", "ContentNode")
  audioContent.url = podcastUrl
  audioContent.contentType = "audio"
  audioContent.streamFormat = "mp3"
  m.audio.content = audioContent

  'for testing
  m.audio.observeField("state", "onAudioStateChange")

  ' m.audio.control = "play"
end sub

sub assignEndTime(duration)
  m.endTime.text = duration
end sub

sub onAudioStateChange(msg as object)
  state = msg.getData()
  ?"STATE CHANGE: "state
end sub

sub playPauseAudio()
  if m.audio.state = "none"
    m.audio.control = "play"
  else if m.audio.state = "playing"
    m.audio.control = "pause"
  else if m.audio.state = "paused"
    m.audio.control = "resume"
  else if m.audio.state = "finished"
    'navigate back to podcastEpisodesPage
    navigateToPage(m.top, "", {})
  end if

end sub

sub updateCurrentSpot(direction as string)
  translation = m.currentSpot.translation
  x = translation[0]
  y = translation[1]

  xAxisChange = int(m.pixelsPerSecond * 15)

  if direction = "right"
    m.currentSpot.translation = [(x + xAxisChange), y]
    m.elapsedSeconds = m.elapsedSeconds + 15

  else if direction = "left"
    m.currentSpot.translation = [(x - xAxisChange), y]
    m.elapsedSeconds = m.elapsedSeconds - 15
  end if

  m.startTime.text = convertSecondsToDuration(m.elapsedSeconds)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if press
    if (key = "OK")
      if m.audio <> invalid
        playPauseAudio()
        handled = true
      end if
    else if (key = "back")
      navigateToPage(m.top, "", {})
      handled = true
    else if (key = "right")
      updateCurrentSpot(key)
    else if (key = "left")
      updateCurrentSpot(key)
    end if
  end if
  return handled
end function
