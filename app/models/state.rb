class State < ActiveRecord::Base
  has_many :cities
  has_many :zip_codes, through: :cities
  has_many :articles, through: :zip_codes
  belongs_to :country
end
