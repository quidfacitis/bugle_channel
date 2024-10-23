sub init()
  m.top.id = "podcastPlayerPage"
  m.dummyLabel = m.top.findNode("dummyLabel")
  m.progressBarContainer = m.top.findNode("progressBarContainer")
  m.currentSpot = m.top.findNode("currentSpot")
  m.endTime = m.top.findNode("endTime")
  assignProgressBarTranslation()
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
  end if
end sub

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


  'TO DO - GET LEFT AND RIGHT PRESSES TO MOVE THE EQUIVALENT OF 15 SECONDS
  if direction = "right"
    m.currentSpot.translation = [(x + 10), y]
  else if direction = "left"
    m.currentSpot.translation = [(x - 10), y]
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
      updateCurrentSpot(key)
    else if (key = "left")
      updateCurrentSpot(key)
    end if
  end if
  return handled
end function
