'courtesy of "lewi-p" from Roku dev forum - https://community.roku.com/t5/Roku-Developer-Program/Strip-out-HTML-Tags/td-p/297198
function stripOutHtmlTags(baseStr as string) as string
  r = createObject("roRegex", "<[^<]+?>", "i")
  return r.replaceAll(baseStr, "")
end function

function getPodcastList()
  return [
    {
      "name": "The Bugle",
      "feed": "https://feeds.acast.com/public/shows/thebugle",
      "img": "pkg:/images/the_bugle_podcast_hd.png"
    }
    {
      "name": "The Gargle",
      "feed": "https://feeds.acast.com/public/shows/the-gargle",
      "img": "pkg:/images/the_gargle_podcast_hd.png"
    },
  ]
end function

function navigateToPage(node as dynamic, pageName as string, params = {}) as boolean
  if node <> invalid
    if node.id = "AppScene"
      node.currentPageParams = params
      node.currentPage = pageName
      return true
    end if
    parentNode = node.getParent()
    navigateToPage(parentNode, pageName, params)
  else
    return false
  end if
end function