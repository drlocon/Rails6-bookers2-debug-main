class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]
  impressionist :actions => [:show]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    impressionist(@book, nil, unique: [:ip_address])
    
    if params[:tag_id]
      @tag_list = Tag.all
      @tag = Tag.find(params[:tag_id])
      @books = @tag.blogs.public_send.order(time: "DESC").page(params[:page]).per(10)
      @books_side = Book.public_send.order(time: "DESC")
    else
      @tag_list = Tag.all
      @books = Book.public_send.order(time: "DESC").page(params[:page]).per(10)
      @books_side = Book.public_send.order(time: "DESC")
    end
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end

  def index
    @book_new = Book.new
    @books = Book.all.order(params[:sort])
  end

  def create
    @book_new = Book.new(book_params)
    @book_new.user_id = current_user.id
    tag_list = params[:book][:tag_name].delete('').delete(' ').split(nil)
    if @book_new.save
      @book_new.save_books(tag_list)
      redirect_to book_path(@book_new.id), notice: "You have created book successfully."
    else
      @user = current_user
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
    @tag_list = @book.tags.pluck(:tag_name).join(',')
  end

  def update
    @book = Book.find(params[:id])
    tag_list = params[:book][:tag_name].delete('').delete(' ').split(',')
    if @book.update(book_params)
      @book.save_books(tag_list)
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
