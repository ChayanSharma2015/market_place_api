class Api::V1::UsersController  < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy, :liked_disliked_user, :show_liked_user, :show_disliked_user]
  respond_to :json
  def show
      respond_with  User.find(params[:id])
  end

  def index

  end

  def create
    user  = User.new(user_params)
    if  user.save
      render  json: user, status: 201,  location: [:api,  user]
    else
      render  json: { errors: user.errors },  status: 422
    end
  end

  def update
    user  = current_user
    if  user.update(user_params)
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

  def liked_disliked_users
    user = LikedDislikedUser.find_or_initialize_by(user_id: current_user.id,
      liked_disliked_user_id: params[:liked_disliked_user].to_i)
    user.update(status: params[:status])
    render  json: "Successfully "+params[:status], status: 200
  end

  def show_liked_users
    liked_users = current_user.liked_disliked_users.where(status: "liked")
    if !liked_users.empty?
      render  json: liked_users, status: 200
    else
      render  json: "No liked users", status: 200
    end
  end

  def show_disliked_users
    disliked_users = current_user.liked_disliked_users.where(status: "disliked")
    if !disliked_users.empty?
      render  json: disliked_users, status: 200
    else
      render  json: "No disliked users", status: 200
    end
  end

  def neutral_users
    all_users = User.pluck(:id)
    liked_disliked_users = current_user.liked_disliked_users.pluck(:id)
    users = all_users.find_all do |user|
      if liked_disliked_users.include? user
         false
      else
         true
      end
    end
    p "===========#{all_users}============="
    p "===========#{liked_disliked_users}============="
    p "===========#{users}============="
    neutral_users = []
    users.each do |user|
      neutral_users << User.find(user)
    end
    render  json: neutral_users, status: 200
  end

  private
    def user_params
        params.require(:user).permit(:email,  :password,  :password_confirmation)
    end
end