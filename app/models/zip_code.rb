class ZipCode < ActiveRecord::Base
  has_many :articles
  belongs_to :city
end
