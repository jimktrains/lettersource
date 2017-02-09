class RedoZip2Cds < ActiveRecord::Migration[5.0]
  def up
    drop_table :zip2cds
    execute "create table zip2cds (zcta5 text[], state text not null, cd text not null primary key);"
    execute "create index zip2cds_zcta5_idx on zip2cds using gin(zcta5);"
    execute "create index zip2cds_state_idx on zip2cds(state);"
  end


  def down
    drop_table :zip2cds
    execute "create table zip2cds (zcta5 text primary key, state text[], cd text[]);"
  end
end
