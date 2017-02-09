class AddAliasesToCategory < ActiveRecord::Migration[5.0]
  def up
    execute <<EOS
CREATE TABLE categories_aliases (
  alias TEXT NOT NULL,
  categories_id ltree REFERENCES categories(path) NOT NULL
);
CREATE INDEX categories_alias_trgm ON categories_aliases USING GIN(alias gin_trgm_ops);
-- this order also allows categories_id to be queried alone on an index if need be
CREATE UNIQUE INDEX categories_alias_category_id_unique_idx ON categories_aliases (categories_id, alias);
ALTER TABLE categories_aliases ADD PRIMARY KEY USING INDEX categories_alias_category_id_unique_idx;
EOS
  end
  def down
    drop_table :categories_aliases
  end
end
