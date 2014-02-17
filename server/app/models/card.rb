class Card < ActiveRecord::Base
  belongs_to :user
  attr_accessible :client_id, :deleted
  image_accessor :image
  file_accessor :audio
end
