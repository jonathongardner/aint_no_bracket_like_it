class CreateTournamentTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :tournament_teams do |t|
      t.belongs_to :team, foreign_key: true, index: true
      t.integer :year, index: true
      t.integer :rank

      t.timestamps
    end
  end
end
