class BookCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @comment = BookComment.new(book_comment_params)
    @comment.user_id = current_user.id 
    @comment.book_id = @book.id
    @comment.save
    redirect_back fallback_location: root_path
  end
  
  def destroy
    @comment = BookComment.find(params[:id])
    @comment.destroy
    redirect_back fallback_location: root_path
  end
  
  private
  
  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end
  
  def ensure_correct_user
    @comment = User.find(params[:id])
    unless @comment.user_id == current_user.id
      redirect_to books_path
    end
  end
  
end
