sub init()
  m.top.id = "AppScene"
  m.top.backgroundUri = ""
  m.top.backgroundColor = "0x000000"

  m.pageContainer = m.top.findNode("pageContainer")
  m.currentPageParams = m.top.currentPageParams
end sub

sub onCurrentPageChange(msg as object)
  pageName = msg.getData()
  'if pageName is an empty string, navigate back
  if pageName = ""
    m.pageContainer.removeChildIndex(0)
    newChildAtZero = m.pageContainer.getChild(0)
    newChildAtZero.visible = true

    if newChildAtZero.hasField("pageParams")
      newChildAtZero.pageParams = m.currentPageParams
    end if

    if newChildAtZero.hasField("initialFocus")
      newChildAtZero.findNode(newChildAtZero.initialFocus).setFocus(true)
    else
      newChildAtZero.getChild(0).setFocus(true)
    end if
  else
    newPage = CreateObject("roSGNode", pageName)
    newPage.id = pageName

    if newPage.hasField("pageParams")
      newPage.pageParams = m.currentPageParams
    end if

    m.pageContainer.insertChild(newPage, 0)
    newPage.setFocus(true)

    childAtOne = m.pageContainer.getChild(1)
    if childAtOne <> invalid
      childAtOne.visible = false
    end if
  end if
end sub

sub onCurrentPageParamsChange(msg as object)
  currentPageParams = msg.getData()
  m.currentPageParams = currentPageParams
end sub
