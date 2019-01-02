class CreateTournamentMatchUps < ActiveRecord::Migration[5.2]
  def change
    create_table :tournament_match_ups do |t|
      t.integer :game
      t.belongs_to :top_tournament_team, foreign_key: {to_table: :tournament_teams}, index: true
      t.belongs_to :bottom_tournament_team, foreign_key: {to_table: :tournament_teams}, index: true
      t.integer :top_team_score
      t.integer :bottom_team_score

      t.timestamps
    end
  end
end
