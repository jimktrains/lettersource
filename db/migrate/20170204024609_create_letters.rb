class CreateLetters < ActiveRecord::Migration[5.0]
  def change
    create_table :letters do |t|
      t.text :title, null: false, limit: 80
      t.text :body, null: false

      t.timestamps
    end
  end
end
