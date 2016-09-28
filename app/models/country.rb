class Country < ActiveRecord::Base
  has_many :states
  has_many :cities, through: :states
  has_many :zip_codes, through: :cities
  has_many :articles, through: :zip_codes
end