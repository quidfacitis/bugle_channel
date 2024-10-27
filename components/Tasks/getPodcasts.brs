sub init()
  m.top.functionName = "getPodcasts"
end sub

sub getPodcasts()
  content = createObject("roSGNode", "ContentNode")
  podcastList = getPodcastList()
  index = 0

  feedUrls = []
  for each podcast in podcastList
    feedUrls.push(podcast.feed)
    podcastPoster = content.createChild("ContentNode")
    'Place podcast name on 'id' field to use when redirecting to podcastEpisodes page
    podcastPoster.id = podcast.name
    podcastPoster.hdGridPosterUrl = podcast.img

    'make 2 rows of 3 podcasts
    if index < 3
      podcastPoster.x = index
      podcastPoster.y = 0
    else
      podcastPoster.x = index - 3
      podcastPoster.y = 1
    end if

    index = index + 1
  end for
  m.top.feedUrls = feedUrls
  m.top.content = content
end sub