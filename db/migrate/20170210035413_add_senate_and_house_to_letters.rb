class AddSenateAndHouseToLetters < ActiveRecord::Migration[5.0]
  def up
    execute <<EOS
create table letters_senate (
  letter_id integer references letters,
  state text references statefips(state)
);
create index letters_senate_state_pk on letters_senate(state);
create unique index letters_senate_pk on letters_senate(letter_id, state);
alter table letters_senate add primary key using index letters_senate_pk;
create table letters_hofr (
  letter_id integer references letters,
  cd text references zip2cds(cd)
);
create index letters_hofr_cd_idx on letters_hofr (cd);
create unique index letters_hofr_pk on letters_hofr(letter_id, cd);
alter table letters_hofr add primary key using index letters_hofr_pk;
EOS
  end

  def down
    drop_table :letters_senate
    drop_table :letters_hofr
  end
end
