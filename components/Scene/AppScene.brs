sub init()
  m.top.id = "AppScene"
  m.pageContainer = m.top.findNode("pageContainer")
  m.currentPageParams = m.top.currentPageParams
end sub

sub onCurrentPageChange(msg as object)
  pageName = msg.getData()

  'TODO - CHECK IF PAGE NAME MACHES LIST OF EXISTING PAGE NAMES

  newPage = CreateObject("roSGNode", pageName)
  newPage.id = pageName

  if newPage.hasField("pageParams")
    newPage.pageParams = m.currentPageParams
  end if

  m.pageContainer.removeChildIndex(0)
  m.pageContainer.appendChild(newPage)
end sub

sub onCurrentPageParamsChange(msg as object)
  currentPageParams = msg.getData()
  m.currentPageParams = currentPageParams
end sub
