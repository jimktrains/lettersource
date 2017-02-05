class AddScoreToLetter < ActiveRecord::Migration[5.0]
  def change
    add_column :letters, :spam_score, :decimal
    add_column :letters, :spam_filters, :text, array: true, default: []
  end
end
