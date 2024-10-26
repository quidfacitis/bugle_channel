sub init()
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
  m.feedUrls = m.getPodcastsTask.feedUrls
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if press
    if (key = "OK")
      focusedIndex = m.podcastPagePosterGrid.itemFocused
      focusedPoster = m.podcastPagePosterGrid.content.getChild(focusedIndex)
      navigateToPage(m.top, "PodcastEpisodesPage", {
        podcastName: focusedPoster.id,
        feedUrl: m.feedUrls[focusedIndex],
        podcastImg: focusedPoster.hdGridPosterUrl
      })
      handled = true
    end if
  end if
  return handled
end function
