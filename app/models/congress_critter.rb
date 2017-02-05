class CongressCritter < ApplicationRecord
  def self.find_by_zip(zip)
    query = <<EOS
select congress_critters.* 
from congress_critters 
inner join zip2cds 
  on (position = 'REP' and ARRAY[cd_fips]::varchar[] <@ cds) 
      or
     (position = 'SEN' AND array[state_fips]::varchar[] <@ states) 
where zipcode = $1
EOS
    conn = ActiveRecord::Base.connection.raw_connection
    begin
      #conn.exec("deallocate get_legislator_for_zip")
      q = conn.prepare("get_legislator_for_zip", query)
    rescue PG::DuplicatePstatement 
    end
    critters_raw = conn.exec_prepared("get_legislator_for_zip",  [zip])
    critters = critters_raw.map {|critter| CongressCritter.new(critter) }
    return critters

  end

  def name
    title + " " + firstname + " " + lastname
  end

  def recipient_array
    return {
      :name => name,
      :street => congress_office,
      :city => "Washington",
      :state => "DC",
      :zip => "20515"
    }
  end
end
