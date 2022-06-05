class Book < ApplicationRecord
  is_impressionable :counter_cache => true
  
  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many :favorited_users, through: :favorites, source: :user
  has_many :book_comments, dependent: :destroy
  
  has_many :tagmaps, dependent: :destroy
  has_many :tags, through: :tagmaps
  
  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}
  
  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end
  
  #検索方法の分岐
  def self.search_for(content, method)
    if method == 'perfect'
      Book.where(title: content)
    elsif method == 'forward'
      Book.where('title LIKE ?', content+'%')
    elsif method == 'backward'
      Book.where('title LIKE ?', '%'+content)
    else
      Book.where('title LIKE ?', '%'+content+'%')
    end
  end
  
  #タグ
  def save_books(tags)
    current_tags = self.tags.pluck(:tag_name) unless self.tags.nil?
    old_tags = current_tags - tags
    new_tags = tags - current_tags
    
    old_tags.each do |old_name|
      self.tags.delete Tag.find_by(tag_name: old_name)
    end
    
    new_tags.each do |new_name|
      book_tag = Tag.find_or_create_by(tag_name: new_name)
      self.tags << book_tag
    end
  end
  
end
