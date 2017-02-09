class Category < ApplicationRecord
  has_and_belongs_to_many :letters 

  def descendant_categories
    query = <<EOS
select *
from categories 
where path <@ (
  select path 
  from categories 
  where id = $1)
order by
  path
EOS
    conn = ActiveRecord::Base.connection.raw_connection
    begin
      conn.exec("deallocate get_category_desc")
      q = conn.prepare("get_category_desc", query)
    rescue PG::DuplicatePstatement 
    end
    categories = conn.exec_prepared("get_category_desc",  [self.id])
    descendants = []
    for category in categories
      descendants << Category.new(category)
    end
    return descendants

  end

  def descendant_letters

    all_letter_query = <<EOS
select letters.*
from letters 
inner join categories_letters
  on letters.id = categories_letters.letter_id
inner join categories
  on categories.id = categories_letters.category_id
where path <@ (
  select path 
  from categories 
  where id = $1)
order by
  path, letters.title
EOS
    conn = ActiveRecord::Base.connection.raw_connection
    begin
      conn.exec("deallocate get_category_desc_letters")
      q = conn.prepare("get_category_desc_letters", all_letter_query)
    rescue PG::DuplicatePstatement 
    end
    letterss = conn.query("get_category_desc_letters",  [self.id])
    letters = []
    for letter in letterss
      letters << Letter.new(letter)
    end
    return letters
  end

  def self.search_with_alias(term)
    query = <<eos
select categories.*
from categories
left join categories_aliases
  on path = categories_id
where name ilike $1
  or alias ilike $1
eos

    conn = ActiveRecord::Base.connection.raw_connection
    categories_raw = conn.query(query, ["%" + term + "%"])
    return categories_raw.map { |c| Category.new(c) }
  end

  # yes, this is ineffeiecnt since we can't load them all for all results in a
  # single query
  def aliases
    query = <<eos
select alias
from categories
inner join categories_aliases
  on path = categories_id
where path = $1
eos

    conn = ActiveRecord::Base.connection.raw_connection
    categories_raw = conn.query(query, [self.path])
    return categories_raw.map { |c| c['alias'] }
  end
end
