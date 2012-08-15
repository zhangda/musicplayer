class Link < ActiveRecord::Base
  attr_accessible :url
  belongs_to :song

end
