class Song < ActiveRecord::Base
  attr_accessible :name
  has_many :links, :dependent => :destroy
 
  def self.has_downloaded?(name)
     song = where("name = ?", name).first
     if song.nil? then 
       false
     else
       if song.created_at < Time.now()-1.day then
          song.destroy
          false
       else
          true
       end
     end
  end

  def self.random_pick
     find(:all, :order => "random()", :limit => 5)
  end
 
end
