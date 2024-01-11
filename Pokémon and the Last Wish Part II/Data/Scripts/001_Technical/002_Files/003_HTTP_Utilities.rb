#############################
#
# HTTP utility functions
#
#############################
def pbPostData(url, postdata, filename=nil, depth=0)
  if url[/^http:\/\/([^\/]+)(.*)$/] || url[/^https:\/\/([^\/]+)(.*)$/]
    host = $1
    path = $2
    path = "/" if path.length==0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14 bot"
    body = postdata.map { |key, value|
      keyString   = key.to_s
      valueString = value.to_s
      keyString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      valueString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      next "#{keyString}=#{valueString}"
    }.join('&')
    ret = HTTPLite.post_body(
      url + '/' + body,
      body,
      "text/plain",
      {
        "Host" => host, # might not be necessary
        "Proxy-Connection" => "Close",
        "Content-Length" => body.bytesize.to_s,
        "Pragma" => "no-cache",
        "User-Agent" => userAgent
      }
    ) rescue ""
    return ret if !ret.is_a?(Hash)
    return "" if ret[:status] != 200
    return ret[:body] if !filename
    File.open(filename, "wb"){|f|f.write(ret[:body])}
    return ""
  end
  return ""
end

def pbPostToWiki(url, postdata, filename=nil, depth=0)
  if url[/^http:\/\/([^\/]+)(.*)$/] || url[/^https:\/\/([^\/]+)(.*)$/]
    host = $1
    path = $2
    path = "/" if path.length==0
    userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14 bot"
    body = postdata.map { |key, value|
      keyString   = key.to_s
      valueString = value.to_s
      keyString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      valueString.gsub!(/[^a-zA-Z0-9_\.\-]/n) { |s| sprintf('%%%02x', s[0]) }
      next "#{keyString}=#{valueString}"
    }.join('&')
    ret = HTTPLite.post_body(
      url,
      body,
      "application/x-www-form-urlencoded",
      {
        "Host" => host, # might not be necessary
        "Proxy-Connection" => "Close",
        "Pragma" => "no-cache",
        "User-Agent" => userAgent
      }
    ) rescue "couldnt post"
    return ret if !ret.is_a?(Hash)
    return "couldnt connect" if ret[:status] != 200
    return ret[:body] if !filename
    File.open(filename, "wb"){|f|f.write(ret[:body])}
    return "didnt get anything"
  end
  return "didnt url"
end

def pbDownloadData(url, filename = nil, authorization = nil, depth = 0, &block)
  headers = {
    "Proxy-Connection" => "Close",
    "Pragma" => "no-cache",
    "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14 bot"
  }
  headers["authorization"] = authorization if authorization
  ret = HTTPLite.get(url, headers) rescue ""
  return ret if !ret.is_a?(Hash)
  return "couldnt connect" if ret[:status] != 200
  return ret[:body] if !filename
  File.open(filename, "wb") { |f| f.write(ret[:body]) }
  return "didnt get anything"
end

COOKIE = "Geo={%22region%22:%22DR%22%2C%22country%22:%22NL%22%2C%22continent%22:%22EU%22}; tracking-opt-in-status=accepted; tracking-opt-in-version=4; wikia_session_id=dm3pn2wfcj; wikia_beacon_id=d96w7cpma3; _b2=1ab3b0292q.1640166368540; euconsent-v2=CPRnYbpPRnYbpCNAEAENB6CsAP_AAH_AACiQIPpB7TrNbSFD-e59dLs0MQxHR0CEIyQiAASBAmABQAKQAKwCgkAZBASABAgCIAAAIAJBAAAECAAACUAAQAAAAAFAAAAABQAIIAIAgAIQAgAIAAAABIEAEAAIgAQAEgAB0ggIAIIACAQAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgfqACIKkxAAUJY4Ek0KRQgABBGAAQAIAIAAIECIAAAABAArAIQQAkAAIAACAAAAAAgBgEAAAgACAAAQAFAAAAAAAAAAAABAAgAAgAAAAAAAAAAAAAEgAAAAAAABAAAAAGBAEAAAAAIAAAAAAAgAAAAAAEAAAAAAAAAAAAAAAAAACAA.YAAAAAAAAAAA; WikiaSessionSource=https%3A%2F%2Fwww.google.com%2F; WikiaLifetimeSource=https%3A%2F%2Fwww.google.com%2F; _ga=GA1.2.1086861347.1640166372; optimizelyEndUserId=oeu1640166372395r0.31577042580051984; __qca=P0-1501449677-1640166372351; _delighted_web={%22walMwZAxr1ygqyqd%22:{%22_delighted_fst%22:{%22t%22:%221640166375360%22}}}; access_token=MmFlODRmYTAtMDExOC00NGYxLTgxN2ItNTNhYTEzYjVkZDEw; fandom_global_id=938e9ea7-1993-413c-b626-79eafe83b470; fandom_session.ver=2; ss_galactus_enabled=true; last_known_wiki=https%3A%2F%2Fskylanders.fandom.com%2Fwiki%2FPortal_of_Power; au_id=AU1D-0100-001648170610-LS04AZUU-ROXS; mediaWikiMigrationBannerClosed1796980=1; csrf_token_7edb4307044064c5213d44940aa94f48ab88fe0b5ead052fbb75851a981aa6c4=H9KY3ICJfaHxuHwB21IOJ+BsCRv/XR1jBMgo2jlcfho=; fandom_session=MTY1MDU2NDgzMnxEdi1CQkFFQ180SUFBUkFCRUFBQVJfLUNBQUVHYzNSeWFXNW5EQThBRFhObGMzTnBiMjVmZEc5clpXNEdjM1J5YVc1bkRDSUFJRE5zYzJwRU5WaEZPRVEwTVVWRlQySkZlVE01YzJzMlNHWjFUelpVV2paQnwlWHDAz7sK15MUG89r2ZoVLRHhD3eSv1Dyd5X-b53_WA==; tracking_session=eyJ1c2VySWQiOiIzODk2MDY4NiJ9; fandom_feeds_hide_deleted=true; _ga=GA1.3.1086861347.1640166372; fandom_feeds_view_mode=standard; wikicities_c11mwuser-sessionId=6d53d376e8fadcf04cc8; mediaWikiMigrationBannerClosed2233=1; i18next=en; VEE=wikitext; tracking_session_id=a8d5df94-033e-4741-a79b-5a5f372448b0; a8d5df94-033e-4741-a79b-5a5f372448b0_basset={%22icStickySlotLineItemIds-0%22:{%22name%22:%22icStickySlotLineItemIds-0%22%2C%22result%22:true%2C%22withCookie%22:true%2C%22group%22:%22B%22%2C%22limit%22:100}}; _gid=GA1.2.1635843692.1652063538; pv_number_global=14; pv_number=14"

def pbDownloadDataWiki(url, filename = nil, authorization = nil, depth = 0, &block)
  headers = {
    "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.14) Gecko/2009082707 Firefox/3.0.14",
    "Cookie" => COOKIE
  }
  headers["authorization"] = authorization if authorization
  ret = HTTPLite.get(url, headers) rescue "get was empty"
  return ret if !ret.is_a?(Hash)
  return "couldnt connect" if ret[:status] != 200
  return ret[:body] if !filename
  File.open(filename, "wb") { |f| f.write(ret[:body]) }
  return "was a hash"
end

def pbDownloadToString(url)
  begin
    data = pbDownloadData(url)
    return data
  rescue
    return ""
  end
end

def pbDownloadToFile(url, file)
  begin
    pbDownloadData(url,file)
  rescue
  end
end

def pbPostToString(url, postdata)
  begin
    data = pbPostData(url, postdata)
    return data
  rescue
    return ""
  end
end

def pbPostToStringWiki(url, postdata)
  begin
    data = pbPostToWiki(url, postdata)
    return data
  rescue
    return ""
  end
end

def pbPostToFile(url, postdata, file)
  begin
    pbPostData(url, postdata,file)
  rescue
  end
end
