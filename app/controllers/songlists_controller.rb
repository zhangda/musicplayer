class SonglistsController < ApplicationController
  require 'open-uri'
  require 'net/http'
  require 'json'
 
  def show
    songs = params[:songs].to_i
    links = params[:links].to_i
    if songs == 0 and links == 0 then
      songs = 2
      links = 2
    end
    count = 0
    threads = []
    new_add = {}
    playlist = get_playlist(songs,"http://mp3skull.com/latest.html")
    playlist.each do |name, page|
      threads[count] = Thread.new {
      	new_add[name] = get_songurl('http://mp3skull.com'<< page, links)
        cover = get_cover(name)
        save_song(name, new_add[name], cover)
        count += 1
      }
    end
    threads.each { |t| t.join }
    @result = Song.random_pick
    respond_to do |format|
      format.html
      #format.json
    end
  end

  private
  def get_playlist(songs, start_page)
    doc = Nokogiri::HTML(open(start_page))
    playlist = {}
    doc.css('#content a').each_with_index do |node, i|
      if i >= songs then break end
      unless Song.has_downloaded?(node.text) then
        playlist[node.text] = node['href']
       #puts node['href']
      end
    end
    playlist
  end

  def get_songurl(page, links)
    params = { 'ord' => 'br' }
    content = Net::HTTP.post_form(URI.parse(page), params).body
    doc = Nokogiri::HTML(content)
    download_list = []
    doc.css('a[@style="color:green;"]').each_with_index do |node, i|
       if i >=links then break end
       download_list << node['href']
       #puts node['href']
    end
    download_list
  end

  def save_song(song_name, song_links, cover)
    ActiveRecord::Base.transaction do
      song = Song.new(:name => song_name, :cover => cover)
      if song.save then
        song_links.each do |t|
          song.links.create(:url => t)
        end
      else
         puts song.errors.full_messages
      end
    end
    ActiveRecord::Base.connection.close
  end


  def get_cover(song_name)
    response = Net::HTTP.get_response(URI.parse("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=" << song_name.gsub(" ","%20"))).body 
    result = JSON.parse(response)
    if result.has_key? 'Error'
      return nil
    end

    result['responseData']['results'].each do |r|
      return r['url']
    end
  end

end
