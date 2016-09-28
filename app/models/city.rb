class City < ActiveRecord::Base
  has_many :zip_codes
  has_many :articles, through: :zip_codes
  belongs_to :state
end
