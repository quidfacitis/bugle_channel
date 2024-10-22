sub init()
  m.top.id = "podcastPlayerPage"
  m.dummyLabel = m.top.findNode("dummyLabel")
end sub

'make task that creates audio node, puts a content node on it, and

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  m.dummyLabel.text = pageParams.episodeTitle

  if pageParams.episodeMetadata <> invalid
    createAudioNode(pageParams.episodeMetadata.enclosure)
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
    end if
  end if
  return handled
end function
