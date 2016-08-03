class Article < ActiveRecord::Base

  has_many :votes,foreign_key: "article_id"
  has_many :positive_votes, -> {where(votes: {vote_status: "positive"})}, through: :votes, source: :article
  has_many :negative_votes, -> {where(votes: {vote_status: "negative"})}, through: :votes, source: :article
  has_many :comments
  has_many :voters, through: :votes, source: :voter
  has_many :positive_voters, -> {where(votes: {vote_status: "positive"})}, through: :votes, source: :voter
  has_many :commenters, through: :comments, source: :user


  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :tags, :through => :taggings
  validates :title, presence: true,
                    length: { minimum: 5, maximum: 50 }
  validates :description, presence: true,
                    length: { maximum: 150 }
  validates :tags, presence: true

  def tag_names
    self.tags.map(&:name).join(", ")
  end

  def tag_names=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create
    end
  end

end
