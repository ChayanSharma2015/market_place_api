class Article < ActiveRecord::Base
  #validates  :title, presence: true,length: { minimum: 5, maximum: 50 }
  #validates  :description, presence: true,length: { maximum: 150 }
  #validates  :tags, presence: true
  validates_numericality_of :user_id
  belongs_to :zip_code
  has_one :city, through: :zip_code
  has_one :state, through: :city
  has_one :country, through: :state

  has_many :comments, dependent: :destroy
  has_many :commenters, through: :comments, source: :user
  has_many :nested_comments, through: :comments, source: :nested_comments

  has_many :votes, dependent: :destroy
  has_many :positive_votes, -> {where(votes: {vote_status: "positive"})}, through: :votes, source: :article, dependent: :destroy
  has_many :negative_votes, -> {where(votes: {vote_status: "negative"})}, through: :votes, source: :article, dependent: :destroy

  has_many :voters, through: :votes, source: :voter
  has_many :positive_voters, -> {where(votes: {vote_status: "positive"})}, through: :votes, source: :voter
  has_many :negative_voters, -> {where(votes: {vote_status: "negative"})}, through: :votes, source: :voter

  has_many :tags, :through => :taggings
  has_many :taggings, dependent: :destroy

  has_many :ratings, class_name:"ArticleRate", dependent: :destroy

  def tag_names
    self.tags.map(&:name).join(", ")
  end

  def tag_names=(names)
    self.tags = names.split(",").map do |n|
      Tag.where(name: n.strip).first_or_create
    end
  end

  def positive_vote_count
    self.positive_votes.count
  end

  def negative_vote_count
    self.negative_votes.count
  end

  def average_rating
    rate_sum = 0
    rating_count = 0
    self.ratings.each do |rating|
      rate_sum += rating.rate
      rating_count += 1
    end
    if rating_count == 0
      average_rating = "No rating yet!"
    else
      average_rating = rate_sum/rating_count
    end
  end
end
