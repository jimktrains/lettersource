class AddPkToStatefips < ActiveRecord::Migration[5.0]
  # So, the :primary => true wasn't the way to set a primary key :(
  def up
    execute "ALTER TABLE statefips DROP id"
    execute "ALTER TABLE statefips ALTER state SET NOT NULL"
    execute "CREATE UNIQUE INDEX statefips_state_pk ON statefips(state)"
    execute "ALTER TABLE statefips ADD PRIMARY KEY USING INDEX statefips_state_pk"
  end
  def down
    execute "ALTER TABLE statefips DROP CONSTRAINT statefips_state_pk"
    execute "DROP INDEX statefips_state_pk"
    execute "ALTER TABLE statefips ALTER state DROP NOT NULL"
    execute "ALTER TABLE statefips ADD id serial primary key"
  end
end
