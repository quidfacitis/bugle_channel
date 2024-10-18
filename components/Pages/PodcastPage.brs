sub init()
  m.top.setFocus(true)
  m.top.id = "podcastPage"
  m.podcastPagePosterGrid = m.top.findNode("podcastPagePosterGrid")
  fireGetPodcastsTask()
end sub

sub fireGetPodcastsTask()
  m.getPodcastsTask = CreateObject("roSGNode", "GetPodcasts")
  m.getPodcastsTask.observeField("content", "placeContentOnPosterGrid")
  m.getPodcastsTask.control = "RUN"
end sub

sub placeContentOnPosterGrid()
  m.podcastPagePosterGrid.content = m.getPodcastsTask.content
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if press
    if (key = "OK")
      'TO DO: REDIRECT TO EPISODES PAGE FOR SELECTED PODCAST
      focusedIndex = m.podcastPagePosterGrid.itemFocused
      focusedPoster = m.podcastPagePosterGrid.content.getChild(focusedIndex)
      ?"***SELECTED PODCAST: "focusedPoster.id
      handled = true
    end if
  end if
  return handled
end function
