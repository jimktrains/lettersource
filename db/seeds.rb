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
    "Technology" => nil,
    "Infrastructure" => nil
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

