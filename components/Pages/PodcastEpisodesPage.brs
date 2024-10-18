sub init()
  m.top.setFocus(true)
  m.temporaryLabel = m.top.findNode("temporaryLabel")
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  pageName = pageParams.pageName
  ?"PAGE NAME IS "pageName
  m.temporaryLabel.text = pageName
end sub

