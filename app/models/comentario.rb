class Comentario < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :foto

  validates :texto, presence: true
end
