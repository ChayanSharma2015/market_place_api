class User < ActiveRecord::Base

  has_many :like_dislikes,foreign_key: "liker_disliker_id"
  has_many :liked_users, ->{where(like_dislikes: {liked_status: true})}, through: :like_dislikes, source: :liked_disliked
  has_many :disliked_users, -> {where(like_dislikes: {liked_status: false})}, through: :like_dislikes,  source: :liked_disliked

  has_many :like_dislikes,foreign_key: "liked_disliked_id"
  has_many :likers, -> {where(like_dislikes: {liked_status: true})}, through: :like_dislikes,  source: :liker_disliker
  has_many :dislikers, -> {where(like_dislikes: {liked_status: false})}, through: :like_dislikes,  source: :liker_disliker

  has_many :articles

  has_many :votes,foreign_key: :voter_id
  has_many :voted_articles, through: :votes, source: :article

  has_many :comments
  has_many :commented_articles, through: :comments, source: :article

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :auth_token,  uniqueness: true

  before_create :generate_authentication_token!

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token:  auth_token)
  end
end
