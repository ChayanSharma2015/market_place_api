class Api::V1::ArticleSerializer < ActiveModel::Serializer

  attributes :id,:title,:description
  has_many :taggings
  has_many :tags, :through => :taggings

end
