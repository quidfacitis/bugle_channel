sub init()
  m.top.functionName = "getPodcastEpisodes"
  m.feedUrl = m.top.feedUrl
end sub

sub onFeedUrlChange(msg as object)
  m.feedUrl = msg.getData()
end sub

sub getPodcastEpisodes()
  content = CreateObject("roSGNode", "ContentNode")

  url = createObject("roUrlTransfer")
  url.SetCertificatesFile("common:/certs/ca-bundle.crt")
  url.InitClientCertificates()
  url.setUrl(m.feedUrl)
  response = url.GetToString()

  xmlObject = createObject("roXMLElement")
  xmlObject.parse(response)
  xmlObject = xmlObject.GetChildElements()
  rawEpisodeArray = xmlObject.GetChildElements()

  parsedEpisodes = []
  for each item in rawEpisodeArray
    if item.getName() = "item"
      episodeData = {}
      episodeDataItems = item.getChildElements()
      for each episodeDatum in episodeDataItems
        episodeData[episodeDatum.getName()] = episodeDatum.getText()
      end for
      labelListItem = content.createChild("ContentNode")
      labelListItem.title = episodeData.title
      parsedEpisodes.push(episodeData)
    end if
  end for

  m.top.episodeMetadata = parsedEpisodes
  m.top.content = content
end sub