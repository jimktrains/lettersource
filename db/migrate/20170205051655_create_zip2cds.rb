class CreateZip2cds < ActiveRecord::Migration[5.0]
	# select
  #   zipcode,
  #   array_agg(distinct state) as states,
  #   array_agg(distinct cd) as cds
  # from (
  #   select
  #     zcta5.zcta5ce10 as zipcode,
  #     cd115.statefp as state,
  #     cd115.geoid as cd
  #   from tiger2016.cd115
  #   left join tiger2016.zcta5
  #     on st_overlaps(zcta5.geom, cd115.geom) or
  #        st_intersects(zcta5.geom, cd115.geom)
  #   group by
  #     zipcode,
  #     state,
  #     cd
  # ) zip2cd
  # group by
  #   zipcode
  def up

		execute <<EOS
CREATE TABLE zip2cds (
    zipcode character varying(5),
    states character varying[],
    cds character varying[]
);
EOS

  end

  def down
    drop_table :zip2cds
  end
end
