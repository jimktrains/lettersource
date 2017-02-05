require 'despamilator'
require 'kramdown' 
class Letter < ApplicationRecord
  has_and_belongs_to_many :categories
  default_scope { where(public: true) }

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

  def save
    dspam = Despamilator.new(body)
    
    self.spam_score = dspam.score
    self.spam_filters = []
    
    dspam.matches.each { |k| self.spam_filters <<  k[:filter].class.to_s + " @ " + k[:score].to_s }

    self.public =  dspam.score < 1
    super
  end
end
