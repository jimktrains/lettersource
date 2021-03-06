require 'despamilator'
require 'kramdown' 
class Letter < ApplicationRecord
  has_and_belongs_to_many :categories
  default_scope { where(public: true) }
  before_save :update_spam_score
  before_create :update_spam_score
  before_update :update_spam_score

  include PgSearch
  # The index must include the weightings and fields
  # see db/migrate/20170204152255_create_full_text_index.rb
  # for an example of how it was initally done.
  #
  # To check if the index is being used `set enable_seqscan=false;`
  # e.g.
  #
  # lettersource_development=> set enable_seqscan=false;
  # lettersource_development=> explain SELECT "letters".* FROM "letters" INNER
  # JOIN (SELECT "letters"."id" AS pg_search_id,
  # (ts_rank((setweight(to_tsvector('english',
  # coalesce("letters"."title"::text, '')), 'A') ||
  # setweight(to_tsvector('english', coalesce("letters"."body"::text, '')),
  # 'B')), (to_tsquery('english', ''' ' || 'tab' || ' ''')), 0)) AS rank FROM
  # "letters" WHERE (((setweight(to_tsvector('english',
  # coalesce("letters"."title"::text, '')), 'A') ||
  # setweight(to_tsvector('english', coalesce("letters"."body"::text, '')),
  # 'B')) @@ (to_tsquery('english', ''' ' || 'tab' || ' '''))))) AS
  # pg_search_7ad8dbe5dbed0dcda5e2fa ON "letters"."id" =
  # pg_search_7ad8dbe5dbed0dcda5e2fa.pg_search_id ORDER BY
  # pg_search_7ad8dbe5dbed0dcda5e2fa.rank DESC, "letters"."id" ASC
  #
  # You'll probably be able to take the query to test against from
  # the sql logs rails runs when you `Letter.search_full_text`
  pg_search_scope :search_full_text,
                  :against => { 
                    :title => 'A',
                    :body  => 'B'
                  },
                  :using => { 
                    :tsearch => { :dictionary => 'english' }
                  }
                                  

  def rendered_body
    # Debating if this should be cached in the db or generated
    # generated allows me to change the rendering...but how often will that
    # happen. For testing it'll stay here, but
    # I probably will end up
    # @TODO move rendering into `Letter#body=`
    doc = Kramdown::Document.new(body)
    rendered_body, warnings = LettersHelper::HTMLConverterWithoutLinks.convert(doc.root)
    return rendered_body
  end

  def update_spam_score
    dspam = Despamilator.new(body)
    self.spam_score = dspam.score
    self.spam_filters = []
    
    dspam.matches.each { |k| self.spam_filters <<  k[:filter].class.to_s + " @ " + k[:score].to_s }

    self.public =  dspam.score < 1
  end


  def self.find_by_zip(zip)
    conn = ActiveRecord::Base.connection.raw_connection
    query = <<EOS
select * from (
  select letters.*
  from letters
  left join (select letter_id 
    from letters_senate
    inner join zip2cds
      on zip2cds.state = letters_senate.state
    where zcta5 @> ARRAY[$1]
  ) letters_senate_zip
    on letters.id = letter_id
  left join (select letter_id 
    from letters_hofr
    inner join zip2cds
      on zip2cds.cd = letters_hofr.cd
    where zcta5 @> ARRAY[$1]
  ) letters_hofr_zip
    on letters.id = letters_hofr_zip.letter_id
  where public
  union all
  select letters.*
  from letters
  left join letters_senate
    on letters.id = letters_senate.letter_id
  left join  letters_hofr
    on letters.id = letters_hofr.letter_id
  where letters_senate.letter_id is null 
    and letters_hofr.letter_id is null
    and public
) letters_for_zip_or_none
group by 
  id, 
  title, 
  body, 
  created_at, 
  updated_at, 
  rendered_body, 
  spam_score, 
  spam_filters, 
  public
EOS
    q = conn.query(query, [zip])
    q.map { |c| Letter.new(c) }
  end
end
