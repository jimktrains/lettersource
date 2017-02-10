class Zip2cd < ApplicationRecord
  def self.find_cd_by_zip(zip)
    query = <<EOS
select cd,
       state,
       stusab,
       state_name
from zip2cds
inner join statefips
  using (state)
where zcta5 @> ARRAY[$1]
EOS
    conn = ActiveRecord::Base.connection.raw_connection
    critters_raw = conn.query(query, [zip])
    return critters_raw.map do |d|  
      next if d['cd'].include? 'ZZ'
      d['id'] = d['cd']
      d['name'] = d['state_name'] + "'s " + d['cd'][2..-1].to_i.ordinalize
      d['type'] = "Federal House of Representatives"
      d
    end.compact
  end

  def self.find_state_by_zip(zip)
    query = <<EOS
select 
       state,
       stusab,
       state_name
from zip2cds
inner join statefips
  using (state)
where zcta5 @> ARRAY[$1]
group by
       state,
       stusab,
       state_name
EOS
    conn = ActiveRecord::Base.connection.raw_connection
    critters_raw = conn.query(query, [zip])
    return critters_raw.map do |d|  
      d['id'] = d['state']
      d['name'] = d['state_name'] 
      d['type'] = "Federal Senate"
      d
    end
  end
end
