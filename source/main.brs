' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub main()
  screen = createObject("roSGScreen")
  m.port = createObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("AppScene")
  screen.Show()
  scene.setField("currentPage", "PodcastPage")
  mainEventLoop()
end sub

sub mainEventLoop()
  while true
    msg = wait(0, m.port)
    if (msg <> invalid)
      msgType = type(msg)
      if msgType = "roSGScreenEvent"
        if msg.isScreenClosed() then return
      end if
    end if
  end while
end sub

