require 'rubygems'

require 'sinatra'
require 'chronic'
require 'haml'
require 'nokogiri'
require 'curb'

BLACKLIST = ["m2pub.com", "180upload.com", "uploadpluz.com", "allmyvideos.net", "nowvideo.eu"]

get "/" do
  return "" unless params[:secret]

  http = Curl.get("http://www.pinoy-ako.info/")
  @body = http.body_str

  @shows = []

  @doc = Nokogiri::HTML @body
  @doc.css('a.latestnews').each do |link|
    show = {href: link.attributes["href"].value, name: link.children.to_s.strip }

    date_parts = show[:name].split("-")
    next unless date_parts.length > 1

    date = Chronic.parse date_parts.last
    next unless date

    @shows << show.merge(date: date)
  end

  @shows = @shows.sort_by { |s| s[:date] }.reverse
  haml :index
end

get "/show" do
  return "" unless params[:secret]

  http = Curl.get("http://www.pinoy-ako.info/#{params[:show]}")
  @body = http.body_str

  @iframes = []

  @doc = Nokogiri::HTML @body
  @doc.css('iframe').each do |iframe|
    next if BLACKLIST.any? { |b| iframe.attributes["src"].value.include?(b) }

    @iframes << iframe
  end

  haml :show
end
