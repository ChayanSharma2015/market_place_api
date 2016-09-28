class Api::V1::ArticlesController  < ApplicationController

  after_action :check_add_petition, only: [:vote,:comment]
  before_action :authenticate_with_token!, only: [:create,:destroy,:my_fav_articles,:vote,:comment,:like,:show,:index]

  def blocked
    my_blockers = current_user.my_blockers.pluck(:id)
    my_blockings = current_user.my_blockings.pluck(:id)
    blocked = my_blockers + my_blockings
    return blocked
  end

  def index
    if blocked.empty?
      all_articles = Article.all
    else
      all_articles = Article.where("user_id NOT IN (?)",blocked.uniq)
    end
    render json: all_articles,include: [:tags], methods: [:positive_vote_count,:negative_vote_count], status: 200
  end

  def my_articles
    my_articles = current_user.articles
    render json: my_articles, status: 200
  end

  def new
    @article = Article.new
  end

  def show
    article = Article.find(params[:id])
    if !blocked.uniq.include? article.user_id
      article = Article.preload(:positive_votes,:negative_votes,:comments,:zip_code,:city,:state,:country).where(id:params[:id]).first
      city           = article.city
      state          = article.state
      country        = article.country
      zip_code       = article.zip_code
      tags           = article.tags
      positive_votes = article.positive_votes.count
      negative_votes = article.negative_votes.count
      average_rating = article.average_rating
      comments = []
      article.comments.where("parent_comment_id IS NULL").each do |comment|
        comments << comment.self_and_children
      end
      respond_to do |format|
        format.json  { render :json => {:article => article,:zip_code => zip_code,:city => city,:state => state,:country => country,:tags => tags,:positive_votes => positive_votes,
          :negative_votes => negative_votes,:comments => comments, :average_rating => average_rating }}
      end
    else
      render json: {message: 'Sorry! You cannot view this article!', success: true}, status: 200
    end
  end

  def create
    country  = Country.where(name:params[:article][:country]).first_or_create.id
    state    = State.where(name:params[:article][:state],country_id:country).first_or_create.id
    city     = City.where(name:params[:article][:city],state_id:state).first_or_create.id
    zip_code = ZipCode.where(number:params[:article][:zip_code],city_id:city).first_or_create.id
    article_hash = article_params
    article_hash[:zip_code_id] = zip_code
    article  = current_user.articles.new(article_hash)
    if article.save
        render json: article, status: 200
    else
      render json: { errors: article.errors },  status: 422
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    render json: "Successfully deleted!", status: 200
  end

  def vote
    article = Article.find_by(id:params[:article_id].to_i)
    if !blocked.uniq.include? article.user_id
      if article.user_id != current_user.id
        vote = Vote.find_or_initialize_by(voter_id: current_user.id,article_id: params[:article_id])
        vote.update(vote_status: params[:vote_status])
        render json: {message: 'Successfully Done', success: true}, status: 200
      else
        render json: {message: 'Sorry! Self voting is not allowed', success: true}, status: 200
      end
    else
      render json: {message: 'Sorry! You cannot vote on this article!', success: true}, status: 200
    end
  end

  def comment
    article = Article.find_by(id:params[:article_id].to_i)
    if !blocked.uniq.include? article.user_id
      if !params[:parent_comment_id].present?
        comment = Comment.new(user_id:current_user.id,article_id:params[:article_id],comment:params[:comment])
        if comment.save
          render json: {message: 'Successfully Done', success: true}, status: 200
        else
          render json: {errors: comment.errors}, status: 422
        end
      else
        comment = Comment.new(user_id:current_user.id,article_id:params[:article_id],
          comment:params[:comment],parent_comment_id:params[:parent_comment_id])
        if comment.save
          render json: {message: 'Successfully Done', success: true}, status: 200
        else
          render json: {errors: comment.errors}, status: 422
        end
      end
    else
      render json: {message: 'Sorry! You cannot comment on this article!', success: true}, status: 200
    end
  end

  def like_unlike_comment
    comment = Comment.find_by(id:params[:comment_id].to_i)
    if !blocked.uniq.include? comment.user_id
      if params[:like_status] == "true"
        CommentLike.create(comment_id:params[:comment_id],user_id:current_user.id)
        render json: {message:'Successfully Liked', success: true}, status: 200
      else
        CommentLike.find_by(comment_id:params[:comment_id],user_id:current_user.id).delete
        render json: {message:'Successfully Unliked', success: true}, status: 200
      end
    else
      render json: {message: 'Sorry! You cannot like or unlike this comment!', success: true}, status: 200
    end
  end

  def rate
    article = Article.find_by(id:params[:article_id].to_i)
    if !blocked.uniq.include? article.user_id
      ArticleRate.create(article_id:params[:article_id],user_id:current_user.id,rate:params[:rate])
      render json: {message:'Successfully Rated', success: true}, status: 200
    else
      render json: {message: 'Sorry! You cannot rate this article!', success: true}, status: 200
    end
  end

  def my_fav_articles
    fav_articles = current_user.articles + current_user.commented_articles.distinct + current_user.voted_articles
    respond_to do |format|
      format.json  { render :json => {:fav_articles => fav_articles }}
    end
  end

  def search_articles
    if params[:country].present?
      all_articles = Country.find_by(name:params[:country]).articles.where("user_id NOT IN (?)",blocked.uniq)
      render json: all_articles
    elsif params[:state].present?
      all_articles = State.find_by(name:params[:state]).articles.where("user_id NOT IN (?)",blocked.uniq)
      render json: all_articles
    elsif params[:city].present?
      all_articles = City.find_by(name:params[:city]).articles.where("user_id NOT IN (?)",blocked.uniq)
      render json: all_articles
    else
      all_articles = ZipCode.find_by(number:params[:zip_code]).articles.where("user_id NOT IN (?)",blocked.uniq)
      render json: all_articles
    end
  end

  private
    def check_add_petition
      article = Article.find_by(id:params[:article_id].to_i)
      if !Petition.find_by(article_id:params[:article_id]).present? &&
        article.positive_votes.count > 1 && article.comments.count > 1
        Petition.create(article_id:article.id)
        commenters_voters = article.commenters.distinct + article.positive_voters + [article.user]
        commenters_voters.uniq.each do |cv|
          NotificationMailer.delay.notification_email(cv.email,article)
        end
      end
    end

    def article_params
      params.require(:article).permit(:title, :description, :tag_names, :zip_code_id)
    end
end