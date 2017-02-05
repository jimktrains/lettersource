class AddRenderedBodyToLetters < ActiveRecord::Migration[5.0]
  def change
    add_column :letters, :rendered_body, :text
  end
end
