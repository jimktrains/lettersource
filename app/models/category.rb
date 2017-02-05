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
    letterss = conn.exec_prepared("get_category_desc_letters",  [self.id])
    letters = []
    for letter in letterss
      letters << Letter.new(letter)
    end
    return letters
  end
end
