class AddPublicToLetter < ActiveRecord::Migration[5.0]
  def change
    add_column :letters, :public, :boolean
  end
end
