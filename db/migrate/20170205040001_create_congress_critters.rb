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

      # So, the :primary => true wasn't the way to set a primary key :(
      # see 20170205145032_add_pk_to_congress_critters.rb
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
      # So, the :primary => true wasn't the way to set a primary key :(
      # see db/migrate/20170205150740_add_pk_to_statefips.rb
      t.text :state, :primary => true 
      t.text :stusab, :index => true
      t.text :state_name
      t.text :statens
    end

  end

  def down
    drop_table :congress_critters
    drop_table :statefips
    execute "DROP TYPE cc_type"
  end
end
