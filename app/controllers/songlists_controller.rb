class SonglistsController < ApplicationController
  require 'open-uri'
  require 'net/http'
 
  def show
    songs = params[:songs].to_i
    links = params[:links].to_i
    if songs == 0 and links == 0 then
      songs = 10
      links = 3
    end
    count = 0
    arr = []
    @result = {}
    playlist = get_playlist(songs)
    playlist.each do |name, page|
      arr[count] = Thread.new {
      	@result[name] = get_songurl('http://mp3skull.com'<< page, links)
        count += 1
      }
    end
    arr.each { |t| t.join }
    respond_to do |format|
      format.html
      format.json
    end
  end

  private
  def get_playlist(songs)
    doc = Nokogiri::HTML(open('http://mp3skull.com/top.html'))
    playlist = {}
    doc.css('#content a').each_with_index do |node, i|
      playlist[node.text] = node['href']
      #puts node['href']
      if i >= songs-1  then break end
    end
    playlist
  end

  def get_songurl(page, links)
    params = { 'ord' => 'br' }
    content = Net::HTTP.post_form(URI.parse(page), params).body
    doc = Nokogiri::HTML(content)
    download_list = []
    doc.css('a[@style="color:green;"]').each_with_index do |node, i|
       download_list << node['href']
       #puts node['href']
       if i >=links-1 then break end
    end
    download_list
  end

end
