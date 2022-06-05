class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]
  impressionist :actions => [:show]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    impressionist(@book, nil, unique: [:ip_address])
  end

  def index
    @book_new = Book.new
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    if params[:latest]
      @books = Book.latest
    elsif params[:star_count]
      @books = Book.star_count
    else
      @books = Book.includes(:favorited_users).
        sort_by {|x|
          x.favorited_users.includes(:favorites).where(created_at: from...to).size
        }.reverse
    end
  end

  def create
    @book_new = Book.new(book_params)
    @book_new.user_id = current_user.id
    if @book_new.save
      redirect_to book_path(@book_new.id), notice: "You have created book successfully."
    else
      @user = current_user
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path, notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :rate)
  end
  
  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user_id == current_user.id
      redirect_to books_path
    end
  end
  
end
