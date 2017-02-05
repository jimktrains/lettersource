class AddPkToZip2cd < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE zip2cds ALTER zipcode SET NOT NULL"
    execute "CREATE UNIQUE INDEX zip2cds_zipcode_pk ON zip2cds(zipcode)"
    execute "ALTER TABLE zip2cds ADD PRIMARY KEY USING INDEX zip2cds_zipcode_pk"
  end
  def down
    execute "ALTER TABLE zip2cds DROP CONSTRAINT zip2cds_zipcode_pk"
    execute "DROP INDEX zip2cds_zipcode_pk"
    execute "ALTER TABLE zip2cds ALTER zipcode DROP NOT NULL"
  end
end
