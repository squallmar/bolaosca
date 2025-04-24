class AddTopoImgToBolaos < ActiveRecord::Migration[8.0]
  def change
    add_column :bolaos, :image, :string, null: true
  end
end
