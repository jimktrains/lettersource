class Adduniquetostatefips < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE statefips ADD CONSTRAINT statefips_state_unique UNIQUE(state)"
  end
end
