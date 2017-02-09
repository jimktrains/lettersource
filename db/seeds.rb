# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db=>seed command (or created alongside the database with db=>setup).
#
# Examples=>
#
#   movies = Movie.create([{ name=> 'Star Wars' }, { name=> 'Lord of the Rings' }])
#   Character.create(name=> 'Luke', movie=> movies.first)



topics = {
  "International Issues" => {
    "Foreign Policy" => nil,
    "Homeland Security" => nil,
    "War & Peace" => nil,
    "Free Trade" => nil,
    "Immigration" => nil,
    "Energy & Oil" => nil
  },

  "Domestic Issues" => {
    "Gun Control" => nil,
    "Crime" => nil,
    "Drugs" => nil,
    "Civil Rights" => nil,
    "Jobs" => nil,
    "Environment" => nil
  },

  "Economic Issues" => {
    "Budget & Economy" => nil,
    "Government Reform" => nil,
    "Tax Reform" => nil,
    "Social Security" => nil,
    "Welfare & Poverty" => nil,
    "Technology" => {
      "Net Neutrality" => nil
    },
    "Infrastructure" => {
      "Public Transit" => nil,
      "State-of-Repair" => nil
    }
  },

  "Social Issues" => {
    "Education" => {
      "Public K-12" => nil,
      "Public Universities" => nil
    },
    "Health Care" => {
      "Affordable Care Act" => nil,
      "Medicare" => nil
    },
    "Abortion" => nil,
    "LGBQT" => nil,
    "Families & Children" => nil,
    "Corporations" => nil,
    "Principles & Values" => nil
  }
}

def clean_path_part(x)
  x.gsub(/[^A-Za-z0-9]/, '_').gsub(/_+/, '_')
end

def handle_topic(topics, prefix=nil, display_prefix=nil)
  if prefix.nil? then
    prefix = ""
  else
    prefix = prefix + "." 
  end

  if display_prefix.nil? then
    display_prefix = ""
  else
    display_prefix = display_prefix + " > " 
  end


  topics.each do |k,v|
    this_prefix = prefix + clean_path_part(k)
    this_display_name = display_prefix  + k
    cat = Category.where(path: this_prefix).first
    if cat.path.nil? then
      Category.create(name: k, path: this_prefix, display_name: this_display_name, public: true)
    else
      cat.name = k
      cat.path = this_prefix
      cat.display_name = this_display_name
      cat.public = true
      cat.save
    end
    if v.is_a? Hash then
      handle_topic(v, this_prefix, this_display_name)
    end
  end
end

Rails.logger.debug("importing topics")
puts "importing topics"
handle_topic(topics)

conn = ActiveRecord::Base.connection.raw_connection

Rails.logger.debug("importing zips")
puts "importing zips"
begin
  filename = "db/zip2cds.sql"
  q = ""
  File.foreach(filename).with_index do |line, line_num|
    if line_num % 100 == 0
      puts line_num
      conn.query q
      q = ""
    end
    q += line
  end
  if q != "" then
      conn.query q
  end
rescue PG::UniqueViolation => e
  puts e
  Rails.logger.error(e)
  Rails.logger.error("Must have alrady imported zips?")
end


require 'csv'


Rails.logger.debug("importing legislators")
puts "importing legislators"

csv_text = File.read('db/legislators.csv')
csv = CSV.parse(csv_text, :headers => true)
not_imported = 0
csv.each do |row|
  begin
    CongressCritter.create!(row.to_hash)
  rescue
    not_imported += 1
  end
end

unless not_imported == 0 then
  puts not_imported.to_s + " Errors importing legislators"
  Rails.logger.error(not_imported.to_s + " Errors importing legislators")
end

Rails.logger.debug("importing states")
puts "importing states"
# http://www2.census.gov/geo/docs/reference/state.txt
not_imported = 0
csv_text = File.read('db/state.txt')
csv = CSV.parse(csv_text, :headers => true, :col_sep => "|", :header_converters=> :downcase)
csv.each do |row|
  begin
    Statefips.create!(row.to_hash)
  rescue
    not_imported += 1
  end
end
unless not_imported == 0 then
  puts not_imported.to_s + " Errors importing states"
  Rails.logger.error(not_imported.to_s + " Errors importing states")
end


Rails.logger.debug("cleaing congress critters")
puts "cleaning congress critters"

conn.query "DELETE FROM congress_critters WHERE in_office = '0'";
conn.query "UPDATE congress_critters SET position = 'SEN' WHERE senate_class IS NOT NULL"
conn.query "UPDATE congress_critters SET position = 'REP' WHERE senate_class IS NULL"
conn.query "UPDATE congress_critters SET state_fips = (SELECT state FROM statefips WHERE congress_critters.state = statefips.stusab)"
conn.query "UPDATE congress_critters SET cd_fips = state_fips || lpad(district::text, 2, '0') WHERE position = 'REP'"
