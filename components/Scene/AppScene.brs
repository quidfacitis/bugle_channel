sub init()
  ' m.top.setFocus(true)
  m.pageContainer = m.top.findNode("pageContainer")
end sub

sub onCurrentPageChange(msg as object)
  pageName = msg.getData()
  'TODO - CHECK IF PAGE NAME MACHES LIST OF EXISTING PAGE NAMES

  newPage = CreateObject("roSGNode", pageName)
  newPage.id = pageName
  ?"***appending new page to page container: "newPage.id
  m.pageContainer.appendChild(newPage)
  podcastPage = m.pageContainer.findNode("podcastPage")
  ' podcastPage.podcastList = getPodcastList()
  ' podcastPage.visible = true
  ' m.top.appendChild(newPage)
  ' m.pageContainer.setFocus(true)
end sub
