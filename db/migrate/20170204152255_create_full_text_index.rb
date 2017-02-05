class CreateFullTextIndex < ActiveRecord::Migration[5.0]
  def up
    execute <<EOS
CREATE INDEX letters_body_ftidx
ON letters
USING GIN(
  (
    (
      setweight(to_tsvector('english'::regconfig, COALESCE(title, ''::text)), 'A'::"char") 
      ||
      setweight(to_tsvector('english'::regconfig, COALESCE(body, ''::text)), 'B'::"char")
    )
  )
)
EOS
  end

  def down
    execute <<EOS
    DROP INDEX letters_body_ftidx
EOS
  end
end
