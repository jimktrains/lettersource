class AddDisplayNameToCategory < ActiveRecord::Migration[5.0]
  def up
    add_column :categories, :display_name, :text
  end
  def down
    remove_column :categories, :display_name
  end
end
