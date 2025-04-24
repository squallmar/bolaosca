class Album < ActiveRecord::Base
  belongs_to :user
  has_many :fotos, dependent: :delete_all

  validates :titulo, presence: true

  def capa
    capa_id.nil? ? fotos.first : fotos.find_by(id: capa_id)
  end
end
