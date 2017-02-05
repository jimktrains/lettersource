class Createzip2cd < ActiveRecord::Migration[5.0]
  def up
    execute "create table zip2cd (zcta5 text primary key, state text[], cd text[]);"
  end


  def down
    drop_table :zip2cd
  end
end
