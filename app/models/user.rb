class User < ActiveRecord::Base

  has_many :like_dislikes,foreign_key: "liker_disliker_id"
  has_many :liked_users, ->{where(like_dislikes: {liked_status: true})}, through: :like_dislikes, source: :liked_disliked
  has_many :disliked_users, -> {where(like_dislikes: {liked_status: false})}, through: :like_dislikes,  source: :liked_disliked

  has_many :like_dislikes,foreign_key: "liked_disliked_id"
  has_many :likers, -> {where(like_dislikes: {liked_status: true})}, through: :like_dislikes,  source: :liker_disliker
  has_many :dislikers, -> {where(like_dislikes: {liked_status: false})}, through: :like_dislikes,  source: :liker_disliker

  has_many :articles,dependent: :destroy

  has_many :votes,foreign_key: :voter_id
  has_many :voted_articles, through: :votes, source: :article

  has_many :comments
  has_many :nested_comments
  has_many :commented_articles, through: :comments, source: :article

  has_many :followers,foreign_key:"followed_id",class_name:"Following"
  has_many :followings,foreign_key:"follower_id",class_name:"Following"
  has_many :my_followers,through: :followers,foreign_key:"followed_id",source: :follower
  has_many :my_followings,through: :followings,foreign_key:"follower_id",source: :followed

  has_many :blockers,foreign_key:"blocked_id",class_name:"Blocking"
  has_many :blockings,foreign_key:"blocker_id",class_name:"Blocking"
  has_many :my_blockers,through: :blockers,foreign_key:"blocked_id",source: :blocker
  has_many :my_blockings,through: :blockings,foreign_key:"blocker_id",source: :blocked

  has_many :sent_convo, foreign_key:"sender_id",class_name:"Conversation"
  has_many :received_convo,foreign_key:"receiver_id",class_name:"Conversation"
  has_many :my_sent_messages,through: :sent_convo,source: :message do
    def provide_receiver(id)
      where(conversations: {receiver_id: id.to_i})
    end
  end
  has_many :my_received_messages,through: :received_convo,source: :message do
    def provide_sender(id)
      where(conversations: {sender_id: id.to_i})
    end
  end

  has_many :receivers, through: :sent_convo, source: :receiver
  has_many :senders,through: :received_convo,source: :sender

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

  def chatted_with
    receivers | senders
  end
end
