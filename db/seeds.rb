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
    if 0 == Category.where(path: this_prefix).length then
      Category.create(name: k, path: this_prefix, display_name: this_display_name, public: true)
    end
    if v.is_a? Hash then
      handle_topic(v, this_prefix, this_display_name)
    end
  end
end

handle_topic(topics)

conn = ActiveRecord::Base.connection.raw_connection

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

conn.query "DELETE FROM congress_critters WHERE in_office = '0'";
conn.query "UPDATE congress_critters SET position = 'SEN' WHERE senate_class IS NOT NULL"
conn.query "UPDATE congress_critters SET position = 'REP' WHERE senate_class IS NULL"
conn.query "UPDATE congress_critters SET state_fips = (SELECT state FROM statefips WHERE congress_critters.state = statefips.stusab)"
conn.query "UPDATE congress_critters SET cd_fips = state_fips || lpad(district::text, 2, '0') WHERE position = 'REP'"
