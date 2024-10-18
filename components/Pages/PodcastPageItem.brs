sub init()
  m.podcastPageItemImg = m.top.findNode("podcastPageItemImg")
  m.podcastPageItemName = m.top.findNode("podcastPageItemName")
  ' m.top.visible = true
end sub

sub onImgChange(msg as object)
  img = msg.getData()
  m.podcastPageItemImg.uri = img
end sub

sub onNameChange(msg as object)
  name = msg.getData()
  ?"***on name change: "name
  m.podcastPageItemName.text = name
  ' if name = "The Bugle"
  '   ?"***SETTING FOCUS ON THE BUGLE"
  '   m.top.setFocus(true)
  ' end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean

  handled = false
  if press
    if (key = "OK")
      handled = true
      ?"***OK PRESSED ON "m.podcastPageItemName.text
    end if
  end if
  return handled
end function