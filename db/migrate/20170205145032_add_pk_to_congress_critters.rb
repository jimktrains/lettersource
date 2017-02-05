class AddPkToCongressCritters < ActiveRecord::Migration[5.0]
  # So, the :primary => true wasn't the way to set a primary key :(
  def up
    execute "ALTER TABLE congress_critters DROP id"
    execute "ALTER TABLE congress_critters ALTER govtrack_id SET NOT NULL"
    execute "CREATE UNIQUE INDEX congress_critters_govtrack_id_pk ON congress_critters(govtrack_id)"
    execute "ALTER TABLE congress_critters ADD PRIMARY KEY USING INDEX congress_critters_govtrack_id_pk"
  end
  def down
    execute "ALTER TABLE congress_critters DROP CONSTRAINT congress_critters_govtrack_id_pk"
    execute "DROP INDEX congress_critters_govtrack_id_pk"
    execute "ALTER TABLE congress_critters ALTER govtrack_id DROP NOT NULL"
    execute "ALTER TABLE congress_critters ADD id serial primary key"
  end

end
