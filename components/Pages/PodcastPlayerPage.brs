sub init()
  m.top.id = "podcastPlayerPage"

  m.andySpinner = m.top.findNode("andySpinner")
  setUpSpinner(m.andySpinner)

  m.podcastArtAndTitleContainer = m.top.findNode("podcastArtAndTitleContainer")
  m.podcastEpisodeArt = m.top.findNode("podcastEpisodeArt")
  m.title = m.top.findNode("title")

  m.playerContainer = m.top.findNode("playerContainer")
  m.progressBarContainer = m.top.findNode("progressBarContainer")
  m.progressBar = m.top.findNode("progressBar")
  m.currentSpot = m.top.findNode("currentSpot")
  m.startTime = m.top.findNode("startTime")
  m.endTime = m.top.findNode("endTime")
  m.playPauseButton = m.top.findNode("playPauseButton")

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
  yTranslation = 900
  m.playerContainer.translation = [xTranslation, yTranslation]
  m.progBarLeftTranslationLimit = xTranslation + 120
  'use 997 pixels instead of 1000 to account for 3-pixel width of currentSpot marker
  m.progBarRightTranslationLimit = m.progBarLeftTranslationLimit + 997
  'assign initial translation of current spot marker
  m.currentSpot.translation = [m.progBarLeftTranslationLimit, (yTranslation + 3)]
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  m.title.text = pageParams.episodeTitle

  if pageParams.elapsedSeconds <> invalid then m.elapsedSeconds = pageParams.elapsedSeconds.toInt()

  if pageParams.episodeMetadata <> invalid
    createAudioNode(pageParams.episodeMetadata.enclosure)
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
  m.audio.observeField("duration", "onAudioDurationChange")
  m.audio.seek = m.elapsedSeconds
  m.audio.control = "play"
end sub

sub assignEndTime(duration)
  m.endTime.text = duration
end sub

sub onAudioDurationChange(msg as object)
  totalSeconds = msg.getData()
  assignEndTime(convertSecondsToDuration(totalSeconds))
  m.totalSeconds = totalSeconds
  m.pixelsPerSecond = getPixelsPerSecond(totalSeconds)
  if m.pageParams.elapsedSeconds <> invalid
    'set currentSpot marker to bookmarked time
    xAxisChange = m.pixelsPerSecond * m.elapsedSeconds
    t = m.currentSpot.translation
    m.currentSpot.translation = [(t[0] + xAxisChange), t[1]]
    'set start time to bookmarked time
    m.startTime.text = convertSecondsToDuration(m.elapsedSeconds)
  end if
end sub

sub onAudioStateChange(msg as object)
  state = msg.getData()

  ?"STATE CHANGE: "state
  '9654 = play triangle
  '9646 = pause rectangle
  if state = "playing"
    m.audioTimer.control = "start"
    m.playPauseButton.text = Chr(9646) + Chr(9646)
    if m.andySpinner.visible
      m.andySpinner.visible = false
      m.podcastArtAndTitleContainer.visible = true
      m.currentSpot.visible = true
      m.playerContainer.visible = true
    end if
    return
  else if state = "finished"
    m.audioTimer.control = "stop"
    if m.elapsedSeconds < m.totalSeconds
      updateCurrentSpot("right")
    else
      fireNavigateBackTimer()
    end if
  else
    m.playPauseButton.text = Chr(9654)
    m.audioTimer.control = "stop"
  end if
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

  if m.elapsedSeconds >= m.totalSeconds and m.audio.state = "playing"
    fireNavigateBackTimer()
  end if

  'only seek new time if interval is FF or RW
  if interval > 1 then seekToNewTime(m.elapsedSeconds)
end sub

sub fireNavigateBackTimer()
  m.navigateBackTimer = CreateObject("roSGNode", "Timer")
  m.navigateBackTimer.duration = 1
  m.navigateBackTimer.repeat = true
  m.navigateBackTimer.observeField("fire", "navigateBackAfterWaiting")
  m.navigateBackTimer.control = "start"
end sub

sub navigateBackAfterWaiting()
  m.navigateBackTimer.control = "stop"
  navigateToPage(m.top, "", {})
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
      ?"***"m.pageParams.podcastName; m.pageParams.episodeMetadata["acast:episodeId"]; m.elapsedSeconds
      saveRegistryValue(m.pageParams.podcastName, m.pageParams.episodeMetadata["acast:episodeId"], m.elapsedSeconds.toStr())
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
