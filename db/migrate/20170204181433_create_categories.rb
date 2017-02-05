class CreateCategories < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'ltree'
    enable_extension 'pg_trgm'

    create_table :categories do |t|
      t.text :name, null: false, limit: 50
      t.boolean :public
      t.timestamps
    end
    add_column :categories, :path, :ltree, null: false, unique: true
    add_index :categories, :path, using: :gist

    create_table :categories_letters, id: false do |t|
      t.belongs_to :category, index: true, null: false
      t.belongs_to :letter, index: true, null: false
    end

    execute <<EOS
CREATE INDEX categories_name_trgm ON categories USING GIN(name gin_trgm_ops)
EOS
  end

  def down
    drop_table :categories_letters
    drop_table :categories
  end
end
