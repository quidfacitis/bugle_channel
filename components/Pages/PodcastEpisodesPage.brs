sub init()
  m.episodeList = m.top.findNode("episodeList")
  m.episodeList.setFocus(true)
  m.episodeList.observeField("itemFocused", "onItemFocusedChange")
  m.episodeList.translation = [960, 100]

  m.title = m.top.findNode("title")
  m.subtitle = m.top.findNode("subtitle")
  m.pubDate = m.top.findNode("pubDate")
  m.duration = m.top.findNode("duration")
  m.description = m.top.findNode("description")

  m.focusedIndex = invalid

  m.pageParams = m.top.pageParams
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  fireGetPodcastEpisodesTask()
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
  if metaData["itunes:subtitle"] <> invalid
    m.subtitle.text = metaData["itunes:subtitle"]
  else
    m.subtitle.text = "A classic episode from " + m.pageParams.pageName
  end if
  m.pubDate.text = shortenPubDate(metaData.pubDate)
  m.duration.text = "Duration: " + metaData["itunes:duration"]
  m.description.text = stripOutHtmlTags(metaData.description)
end sub

function shortenPubDate(pubDate) as string
  pubDate = pubDate.split(" ")
  pubDate = pubDate.slice(0, 4)
  return pubDate.join(" ")
end function

