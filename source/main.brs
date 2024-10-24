' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub main()
  screen = createObject("roSGScreen")
  m.port = createObject("roMessagePort")
  screen.setMessagePort(m.port)


  'TO DO - CLEAN UP COMMENTED-OUT CODE -- EPISODE-POPULATING LOGIC SHOULD BELONG TO A GIVEN PODCASTS'S EPISODES PAGE


  ' LoadConfig() 'Loads variables inside config.brs file

  ' m.glb = screen.getGlobalNode()
  ' m.glb.addField("FF", "int", true) 'To be used for trickplay functions in XML component
  ' m.glb.FF = 0
  ' m.glb.addField("Rewind", "int", true) 'To be used for trickplay functions in XML component
  ' m.glb.Rewind = 0

  ' m.glb.addField("SummaryColor", "string", true) 'Global variable to be passed as Podcast description text color
  ' m.glb.SummaryColor = m.SummaryColor
  ' m.glb.addField("ListColor", "string", true) 'Global variable to be passed as Podcast List text color
  ' m.glb.ListColor = m.ListColor
  ' m.glb.addField("reverseOrder", "boolean", true) 'Global variable to be passed as podcast sorting order
  ' m.glb.reverseOrder = m.reverseOrder

  ' RSSParse()
  scene = screen.CreateScene("AppScene")
  screen.Show()

  scene.setField("currentPage", "PodcastPage")

  ' scene.listContent = m.TopContent 'Content for Podcasts - set in RSSParse.brs

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

