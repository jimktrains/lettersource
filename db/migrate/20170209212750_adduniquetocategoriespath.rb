class Adduniquetocategoriespath < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE categories ADD CONSTRAINT categories_path_unique UNIQUE (path);"
  end

  def down
    execute "ALTER TABLE categories DROP CONSTRAINT categories_path_unique;"
  end
end
