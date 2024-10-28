sub init()
  m.top.id = "podcastPlayerPage"

  m.andySpinner = m.top.findNode("andySpinner")
  setUpSpinner(m.andySpinner)

  m.podcastArtAndTitleContainer = m.top.findNode("podcastArtAndTitleContainer")
  m.podcastEpisodeArt = m.top.findNode("podcastEpisodeArt")
  m.title = m.top.findNode("title")
  m.progressBarContainer = m.top.findNode("progressBarContainer")
  m.progressBar = m.top.findNode("progressBar")
  m.currentSpot = m.top.findNode("currentSpot")
  m.startTime = m.top.findNode("startTime")
  m.endTime = m.top.findNode("endTime")

  assignProgressBarContainerTranslation()
  setUpAudioTimer()

  m.elapsedSeconds = 0
  m.ffRwInterval = 15
  m.pendingPixelsToMove = 0
  m.FfOrRwOccurred = false
end sub

sub assignProgressBarContainerTranslation()
  boundingRect = m.progressBarContainer.boundingRect()
  xTranslation = (1920 - boundingRect.width) / 2
  yTranslation = 800
  m.progressBarContainer.translation = [xTranslation, yTranslation]
  'assign initial translation of current spot marker
  m.progBarLeftTranslationLimit = xTranslation + 120
  m.progBarRightTranslationLimit = m.progBarLeftTranslationLimit + 1000
  m.currentSpot.translation = [m.progBarLeftTranslationLimit, (yTranslation - 15)]
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  m.title.text = pageParams.episodeTitle

  if pageParams.episodeMetadata <> invalid
    createAudioNode(pageParams.episodeMetadata.enclosure)
    assignEndTime(pageParams.episodeMetadata["itunes:duration"])
    m.totalSeconds = convertDurationToSeconds(pageParams.episodeMetadata["itunes:duration"])
    m.pixelsPerSecond = getPixelsPerSecond(m.totalSeconds)
    if pageParams.episodeMetadata["itunes:image"] <> invalid and pageParams.episodeMetadata["itunes:image"] <> ""
      m.podcastEpisodeArt.uri = pageParams.episodeMetadata["itunes:image"]
    else
      m.podcastEpisodeArt.uri = pageParams.defaultPodcastImg
    end if
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
  else if secs.toStr().len() = 1
    secs = "0" + secs.toStr()
  else
    secs = secs.toStr()
  end if

  return minutes + ":" + secs
end function

function getPixelsPerSecond(totalSeconds as integer) as float
  return m.progressBar.width / totalSeconds
end function


sub setUpAudioTimer()
  m.audioTimer = CreateObject("roSGNode", "Timer")
  m.audioTimer.duration = 1
  m.audioTimer.repeat = true
  m.audioTimer.observeField("fire", "updateCurrentSpot")
end sub

sub createAudioNode(podcastUrl as string)
  m.audio = createObject("roSGNode", "audio")
  audioContent = createObject("roSGNode", "ContentNode")
  audioContent.url = podcastUrl
  audioContent.contentType = "audio"
  audioContent.streamFormat = "mp3"
  m.audio.content = audioContent

  m.audio.observeField("state", "onAudioStateChange")

  m.audio.control = "play"
end sub

sub assignEndTime(duration)
  m.endTime.text = duration
end sub

sub onAudioStateChange(msg as object)
  state = msg.getData()
  if state = "playing"
    m.audioTimer.control = "start"
    if m.andySpinner.visible
      m.andySpinner.visible = false
      m.podcastArtAndTitleContainer.visible = true
      m.currentSpot.visible = true
      m.progressBarContainer.visible = true
    end if
  else
    m.audioTimer.control = "stop"
  end if
  ?"STATE CHANGE: "state
end sub

sub playPauseAudio()
  if m.audio.state = "none"
    m.audio.seek = m.elapsedSeconds
    m.audio.control = "play"
  else if m.audio.state = "playing"
    m.audio.control = "pause"
  else if m.audio.state = "paused"
    if m.FfOrRwOccurred
      m.audio.seek = m.elapsedSeconds
      m.FfOrRwOccurred = false
    else
      m.audio.control = "resume"
    end if
  else if m.audio.state = "finished"
    'navigate back to podcastEpisodesPage
    navigateToPage(m.top, "", {})
  end if

end sub

sub updateCurrentSpot(direction = "right" as string, interval = 1 as integer)
  translation = m.currentSpot.translation
  x = translation[0]
  y = translation[1]

  xAxisChange = m.pixelsPerSecond * interval

  if direction = "right"
    change = x + xAxisChange
    ?"***CHANGE: "change
    if change > m.progBarRightTranslationLimit
      change = m.progBarRightTranslationLimit
      m.elapsedSeconds = m.totalSeconds
    else
      m.elapsedSeconds = m.elapsedSeconds + interval
    end if
    m.currentSpot.translation = [change, y]
  else if direction = "left"
    change = x - xAxisChange
    if change < m.progBarLeftTranslationLimit
      change = m.progBarLeftTranslationLimit
      m.elapsedSeconds = 0
    else
      m.elapsedSeconds = m.elapsedSeconds - interval
    end if
    m.currentSpot.translation = [change, y]
  end if

  ?"CURRENT POSITION: "m.elapsedSeconds
  m.startTime.text = convertSecondsToDuration(m.elapsedSeconds)
  'only seek new time if interval is FF or RW
  if interval > 1 then seekToNewTime(m.elapsedSeconds)
end sub

sub seekToNewTime(newTime)
  if m.audio.state = "playing"
    m.audio.seek = newTime
  else
    m.FfOrRwOccurred = true
  end if
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
      updateCurrentSpot(key, m.ffRwInterval)
    else if (key = "left")
      updateCurrentSpot(key, m.ffRwInterval)
    end if
  end if
  return handled
end function
