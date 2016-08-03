class Api::V1::ArticlesController  < ApplicationController
  def index
    all_articles = Article.all
    render json: all_articles, status: 200
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
    tags = article.tags
    positive_votes = article.positive_votes.count
    negative_votes = article.negative_votes.count
    comments = article.comments
    respond_to do |format|
      format.json  { render :json => {:article => article, :tags => tags,:positive_votes => positive_votes,
       :negative_votes => negative_votes, :comments => comments }}
    end
  end

  def create
    article = current_user.articles.new(article_params)
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
    if article.user.id != current_user.id
      vote = Vote.find_or_initialize_by(voter_id: current_user.id,article_id: params[:article_id])
      vote.update(vote_status: params[:vote_status])
      if !Petition.find_by(article_id:params[:article_id]).present? &&
        article.positive_votes.count > 1 && article.comments.count > 1
        Petition.create(article_id:article.id)

        commenters_voters = article.commenters.distinct + article.positive_voters
        commenters_voters.uniq.each do |cv|
          NotificationMailer.notification_email(cv.email).deliver_now
        end
        render json: {message: 'Successfully voted', success: true}, status: 200
      else
        render json: {message: 'Successfully voted', success: true}, status: 200
      end
    else
      render json: {message: 'Sorry! Self voting is not allowed', success: true}, status: 200
    end
  end

  def comment
    article = Article.find_by(id:params[:article_id].to_i)
    comment = Comment.new(user_id:current_user.id,article_id:params[:article_id],comment:params[:comment])
    if comment.save
      if !Petition.find_by(article_id:params[:article_id]).present? && article.positive_votes.count > 1 && article.comments.count > 1
        Petition.create(article_id:article.id)
        render json: comment, status: 200
      else
        render json: comment, status: 200
      end
    else
      render json: {errors: comment.errors}, status: 422
    end
  end

  def my_fav_articles
    my_articles           = current_user.articles
    my_commented_articles = current_user.commented_articles.distinct
    my_voted_articles     = current_user.voted_articles

    respond_to do |format|
      format.json  { render :json => {:my_articles => my_articles, :my_commented_articles => my_commented_articles,
        :my_voted_articles => my_voted_articles }}
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :description, :tag_names)
    end
end
