class Api::V1::UsersController  < ApplicationController
  before_action :authenticate_with_token!, except: [:create]
  respond_to :json

  def blocked
    my_blockers = current_user.my_blockers.pluck(:id)
    my_blockings = current_user.my_blockings.pluck(:id)
    blocked = my_blockers + my_blockings
    return blocked
  end

  def show
    respond_with  User.find(params[:id])
  end

  def create
    otp = (('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a).shuffle.first(8).join
    user_hash = user_params
    user_hash[:password] = otp
    user_hash[:password_confirmation] = otp
    user  = User.new(user_hash)
    # user.update(password:otp,password_confirmation:otp)
    if user.save
      NotificationMailer.otp_email(user.email,otp).deliver_now
      render  json: user, status: 200,  location: [:api,  user]
    else
      render  json: { errors: user.errors },  status: 422
    end
  end

  def update
    user  = current_user
    if user.update(user_params)
      render  json: user, status: 200,  location: [:api,  user]
    else
      render  json: { errors: user.errors },  status: 422
    end
  end

  def destroy
    user  = current_user
    user.destroy
    head  204
  end

  def like_dislike_user
    user = LikeDislike.find_or_initialize_by(liker_disliker_id: current_user.id,
      liked_disliked_id: params[:user].to_i)
    user.update(liked_status: params[:liked_status])
    if params[:liked_status] == true
      render  json: {message: 'Successfully liked', success: true}, status: 200
    else
      render  json: {message: 'Successfully disliked', success: true}, status: 200
    end
  end

  def liked_users
    liked_users = current_user.liked_users
    render  json: liked_users, status: 200
  end

  def disliked_users
    disliked_users = current_user.disliked_users
    render json: disliked_users, status: 200
  end

  def neutral_users
    liked_disliked_users = []
    liked_disliked_users << current_user.id
    liked_disliked_users << current_user.liked_disliked_users.pluck(:liked_disliked_id)
    users = User.where.not(id: liked_disliked_users)
    render json: users, status: 200
  end

  def my_likers
    likers = current_user.likers
    render json: likers, status: 200
  end

  def my_dislikers
    dislikers = current_user.dislikers
    render json: dislikers, status: 200
  end

  def follow_unfollow
    begin
      raise "INVALID ID!" unless params[:followed_id].is_number?
        if params[:follow] == "true"
          Following.create(follower_id:current_user.id,followed_id:params[:followed_id])
          render json: {message:'Successfully followed', success: true}, status: 200
        else
          Following.find_by(follower_id:current_user.id,followed_id:params[:followed_id]).delete
          render json: {message:'Successfully unfollowed', success: true}, status: 200
        end
      rescue RuntimeError => e
        render json: {error: e.message}
    end
  end

  def block_unblock
    begin
      raise "INVALID ID!" unless params[:blocked_id].is_number?
        if params[:block] == "true"
          Blocking.create(blocker_id:current_user.id,blocked_id:params[:blocked_id])
          render json: {message:'Successfully blocked', success: true}, status: 200
        else
          Blocking.find_by(blocker_id:current_user.id,blocked_id:params[:blocked_id]).delete
          render json: {message:'Successfully unblocked', success: true}, status: 200
        end
      rescue RuntimeError => e
        render json: {error: e.message}
    end
  end

  def message
    begin
      raise "INVALID ID!" unless params[:receiver_id].is_number?
        if !blocked.uniq.include? params[:receiver_id].to_i
          message = Message.create(text:params[:message])
          Conversation.create(sender_id:current_user.id,receiver_id:params[:receiver_id],message_id:message.id)
          render json: {message:'Message Successfully Sent!', success: true}, status: 200
        else
          render json: {message: 'Sorry! You cannot message this User!', success: true}, status: 200
        end
      rescue RuntimeError => e
        render json: {error: e.message}
    end
  end

  def my_convo
    begin
      raise "INVALID ID!" unless params[:user_id].is_number?
        sent_texts     = current_user.my_sent_messages.provide_receiver(params[:user_id])
        received_texts = current_user.my_received_messages.provide_sender(params[:user_id])
        convo          = sent_texts + received_texts
        sorted_convo   = convo.sort
        render json: sorted_convo,include: [:sender], status: 200
      rescue RuntimeError => e
        render json: {error: e.message}
    end
  end

  def all_convo
    my_all_convo = []
    current_user.chatted_with.each do |receiver|
      sent_texts     = current_user.my_sent_messages.provide_receiver(receiver.id)
      received_texts = current_user.my_received_messages.provide_sender(receiver.id)
      convo          = sent_texts + received_texts
      last_text      = convo.sort.last.attributes.merge(chatted_with:receiver)
      my_all_convo << last_text
    end
    render json: my_all_convo, status: 200
  end

  private
    def user_params
        params.require(:user).permit(:email,:password,:password_confirmation)
    end
end

class String
  def is_number?
    true if Float self rescue false
  #   if Float self
  #     return true
  #   end
  #   rescue ArgumentError => e
  #     p "===========#{e.message}============="
  #     return false
  end
end
