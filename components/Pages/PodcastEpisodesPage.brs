sub init()
  m.top.id = "podcastEpisodesPage"
  m.andySpinner = m.top.findNode("andySpinner")
  setUpSpinner(m.andySpinner)

  m.episodeList = m.top.findNode("episodeList")
  m.episodeList.setFocus(true)
  m.episodeList.observeField("itemFocused", "onItemFocusedChange")
  m.episodeList.translation = [960, 100]

  m.pubDateAndDurationContainer = m.top.findNode("pubDateAndDurationContainer")
  m.podcastImg = m.top.findNode("podcastImg")
  m.title = m.top.findNode("title")
  m.subtitleDivider = m.top.findNode("subtitleDivider")
  m.subtitle = m.top.findNode("subtitle")
  m.pubDate = m.top.findNode("pubDate")
  m.duration = m.top.findNode("duration")

  m.focusedIndex = invalid
  m.pageParams = m.top.pageParams
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()

  if m.pageParams.count() = 0
    m.pageParams = pageParams
    m.podcastImg.uri = m.pageParams.podcastImg
    ?"***FIRING GET PODCAST EPISODES TASK"
    fireGetPodcastEpisodesTask()
  end if

  m.episodeBookmarks = loadRegistrySection(m.pageParams.podcastName)
  ?"EPISODE BOOKMARKS: "m.episodeBookmarks
end sub

sub fireGetPodcastEpisodesTask()
  m.getPodcastEpisodesTask = CreateObject("roSGNode", "GetPodcastEpisodes")
  m.getPodcastEpisodesTask.observeField("content", "placeContentOnLabelList")
  m.getPodcastEpisodesTask.observeField("episodeMetadata", "onEpisodeMetadataChange")
  m.getPodcastEpisodesTask.feedUrl = m.pageParams.feedUrl
  m.getPodcastEpisodesTask.control = "RUN"
end sub

sub placeContentOnLabelList()
  m.episodeList.content = m.getPodcastEpisodesTask.content
  m.andySpinner.visible = false
  m.episodeList.visible = true
  m.podcastImg.visible = true
end sub

sub onEpisodeMetadataChange(msg as object)
  m.episodeMetadata = msg.getData()
end sub

sub onItemFocusedChange(msg as object)
  focusedIndex = msg.getData()
  if m.focusedIndex <> invalid and m.focusedIndex = focusedIndex
    return
  else if focusedIndex <> invalid and m.episodeMetadata.count() > 0
    m.focusedIndex = focusedIndex
    setText(m.episodeMetadata[focusedIndex])
  end if
end sub

sub setText(metadata)
  m.title.text = metaData.title
  if metaData["itunes:subtitle"] <> invalid and metaData["itunes:subtitle"] <> ""
    m.subtitle.text = replaceHtmlEntities(metaData["itunes:subtitle"])
    m.subtitle.visible = true
    m.subtitleDivider.visible = true
  else
    m.subtitle.text = ""
    m.subtitle.visible = false
    m.subtitleDivider.visible = false
  end if
  m.pubDate.text = shortenPubDate(metaData.pubDate)
  m.duration.text = "Duration: " + metaData["itunes:duration"]

  pubDateAndDurationBoundingRect = m.pubDateAndDurationContainer.boundingRect()
  xTranslation = (800 - pubDateAndDurationBoundingRect.width) / 2
  m.pubDateAndDurationContainer.translation = [xTranslation, 0]
  m.pubDateAndDurationContainer.visible = true
end sub

function shortenPubDate(pubDate) as string
  pubDate = pubDate.split(" ")
  pubDate = pubDate.slice(0, 4)
  return pubDate.join(" ")
end function

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if press
    if (key = "back")
      navigateToPage(m.top, "", {})
      handled = true
    else if (key = "OK")
      navigateToPage(m.top, "PodcastPlayerPage", {
        episodeTitle: m.title.text,
        episodeMetadata: m.episodeMetadata[m.focusedIndex],
        defaultPodcastImg: m.pageParams.podcastImg,
        podcastName: m.pageParams.podcastName,
        elapsedSeconds: m.episodeBookmarks[m.episodeMetadata[m.focusedIndex]["acast:episodeId"]]
      })
      handled = true
    end if
  end if
  return handled
end function
