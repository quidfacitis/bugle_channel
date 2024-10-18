sub init()
  m.top.functionName = "getPodcasts"
end sub

sub getPodcasts()
  content = createObject("roSGNode", "ContentNode")
  podcastList = getPodcastList()
  index = 0
  for each podcast in podcastList
    podcastPoster = content.createChild("ContentNode")
    'Place podcast name on 'id' field to use when redirecting to podcastEpisodes page
    podcastPoster.id = podcast.name
    podcastPoster.hdGridPosterUrl = podcast.img
    podcastPoster.x = index
    podcastPoster.y = 0
    index = index + 1
  end for
  m.top.content = content
end sub