class Api::V1::UsersController  < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy, :liked_disliked_user, :show_liked_user, :show_disliked_user]
  respond_to :json
  def show
    respond_with  User.find(params[:id])
  end

  def create
    user  = User.new(user_params)
    if user.save
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

  private
    def user_params
        params.require(:user).permit(:email,  :password,  :password_confirmation)
    end
end