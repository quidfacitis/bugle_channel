sub init()
  m.top.id = "AppScene"
  m.pageContainer = m.top.findNode("pageContainer")
  m.currentPageParams = m.top.currentPageParams
end sub

sub onCurrentPageChange(msg as object)
  pageName = msg.getData()

  'TODO - CHECK IF PAGE NAME MACHES LIST OF EXISTING PAGE NAMES

  'if pageName is an empty string, navigate back
  if pageName = ""
    m.pageContainer.removeChildIndex(0)
    newChildAtZero = m.pageContainer.getChild(0)
    newChildAtZero.visible = true
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
