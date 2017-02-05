class CreateCongressCritters < ActiveRecord::Migration[5.0]
  def up
    # taken from 
    # https://sunlightlabs.github.io/congress/
    # http://unitedstates.sunlightfoundation.com/legislators/legislators.csv
    create_table :congress_critters do |t|
      t.text :title 
      t.text :firstname 
      t.text :middlename 
      t.text :lastname 
      t.text :name_suffix 
      t.text :nickname 
      t.text :party 
      t.text :state 
      t.text :district 
      t.text :in_office 
      t.text :gender 
      t.text :phone 
      t.text :fax 
      t.text :website 
      t.text :webform 
      t.text :congress_office 
      t.text :bioguide_id 
      t.text :votesmart_id 
      t.text :fec_id 
      t.text :govtrack_id, :primary => true
      t.text :crp_id 
      t.text :twitter_id 
      t.text :congresspedia_url 
      t.text :youtube_url 
      t.text :facebook_id 
      t.text :official_rss 
      t.text :senate_class 
      t.text :birthdate 
      t.text :oc_email 

      t.text :state_fips
      t.text :cd_fips
    end

    execute "CREATE TYPE cc_type AS ENUM('REP', 'SEN');"
    add_column :congress_critters, :position, "cc_type"

    create_table :statefips do |t|
      t.text :state, :primary => true 
      t.text :stusab, :index => true
      t.text :state_name
      t.text :statens
    end

    require 'csv'    

    csv_text = File.read('db/legislators.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      CongressCritter.create!(row.to_hash)
    end

    # http://www2.census.gov/geo/docs/reference/state.txt
    csv_text = File.read('db/state.txt')
    csv = CSV.parse(csv_text, :headers => true, :col_sep => "|", :header_converters=> :downcase)
    csv.each do |row|
      Statefips.create!(row.to_hash)
    end

    execute "DELETE FROM congress_critters WHERE in_office = '0'";
    execute "UPDATE congress_critters SET position = 'SEN' WHERE senate_class IS NOT NULL"
    execute "UPDATE congress_critters SET position = 'REP' WHERE senate_class IS NULL"
    execute "UPDATE congress_critters SET state_fips = (SELECT state FROM statefips WHERE congress_critters.state = statefips.stusab)"
    execute "UPDATE congress_critters SET cd_fips = state_fips || lpad(district::text, 2, '0') WHERE position = 'REP'"
  end

  def down
    drop_table :congress_critters
    drop_table :statefips
    execute "DROP TYPE cc_type"
  end
end
