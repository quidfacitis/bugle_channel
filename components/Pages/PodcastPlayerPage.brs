sub init()
  m.top.id = "podcastPlayerPage"
  m.dummyLabel = m.top.findNode("dummyLabel")
end sub

sub onPageParamsChange(msg as object)
  pageParams = msg.getData()
  m.pageParams = pageParams
  m.dummyLabel.text = pageParams.episodeTitle
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  handled = false
  if press
    if (key = "back")
      navigateToPage(m.top, "", {})
      handled = true
    end if
  end if
  return handled
end function
